def send_two_factor_email(destinatario, codigo)
  Pony.mail(
    to: destinatario,
    subject: "Tu código de verificación",
    html_body: "
      <h2>Verificación en dos pasos</h2>
      <p>Tu código es:</p>
      <h1 style='font-size:32px;'>#{codigo}</h1>
      <p>Este código es válido por 5 minutos.</p>
    "
  )
end
