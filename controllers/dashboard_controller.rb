require 'sinatra/base'
require 'json'
require_relative '../database'

class DashboardController < Sinatra::Base
  before do
    content_type :json
  end

  # GET /dashboard/summary?user_id=:id&period=month&year=2025&month=11
  get '/dashboard/summary' do
    begin
      user_id = params['user_id']
      period = params['period'] || 'month'
      year = params['year'] || Time.now.year
      month = params['month'] || Time.now.month

      if user_id.nil? || user_id.strip.empty?
        halt 400, { status: 'error', message: 'El parámetro user_id es obligatorio' }.to_json
      end

      # Calcular fechas según periodo
      if period == 'month'
        fecha_inicio = "#{year}-#{month.to_s.rjust(2, '0')}-01"
        # Último día del mes
        ultimo_dia = Date.new(year.to_i, month.to_i, -1).day
        fecha_fin = "#{year}-#{month.to_s.rjust(2, '0')}-#{ultimo_dia}"
      else
        # Por defecto mes actual
        fecha_inicio = Time.now.strftime('%Y-%m-01')
        fecha_fin = Time.now.strftime('%Y-%m-%d')
      end

      # Total gastado
      query_total = <<~SQL
        SELECT COALESCE(SUM(R.monto), 0) as total
        FROM Registro R
        JOIN TipoTransaccion T ON R.idTipoTransaccion = T.id
        WHERE R.idUsuario = ? 
          AND T.nombre = 'gasto'
          AND date(R.fechaHora) BETWEEN ? AND ?
      SQL
      total_spent = DB.execute(query_total, [user_id, fecha_inicio, fecha_fin]).first['total']

      # Top 3 categorías
      query_top = <<~SQL
        SELECT C.nombre as categoria, SUM(R.monto) as monto
        FROM Registro R
        JOIN Categoria C ON R.idCategoria = C.id
        JOIN TipoTransaccion T ON R.idTipoTransaccion = T.id
        WHERE R.idUsuario = ?
          AND T.nombre = 'gasto'
          AND date(R.fechaHora) BETWEEN ? AND ?
        GROUP BY C.id
        ORDER BY monto DESC
        LIMIT 3
      SQL
      top_categorias = DB.execute(query_top, [user_id, fecha_inicio, fecha_fin])

      # Calcular porcentajes
      top_categorias_formatted = top_categorias.map do |cat|
        porcentaje = total_spent > 0 ? (cat['monto'].to_f / total_spent.to_f * 100).round(1) : 0
        {
          categoria: cat['categoria'],
          monto: cat['monto'].to_f,
          porcentaje: porcentaje
        }
      end

      status 200
      {
        period: "#{year}-#{month.to_s.rjust(2, '0')}",
        total_spent: total_spent.to_f,
        top_categories: top_categorias_formatted,
        trend: {
          message: "Resumen del periodo #{year}-#{month}"
        }
      }.to_json
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end

  # GET /dashboard/total-balance?user_id=:id - Balance total (suma de todas las cuentas)
  get '/dashboard/total-balance' do
    begin
      user_id = params['user_id']

      if user_id.nil? || user_id.strip.empty?
        halt 400, { status: 'error', message: 'El parámetro user_id es obligatorio' }.to_json
      end

      query = "SELECT COALESCE(SUM(saldo), 0) as balance FROM Cuenta WHERE idUsuario = ?"
      result = DB.execute(query, [user_id]).first

      status 200
      {
        user_id: user_id.to_i,
        total_balance: result['balance'].to_f
      }.to_json
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end
end
