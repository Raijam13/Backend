module GenericResponse
  def generic_response(success, message, data = nil, error = nil, status_code = 200)
    status status_code
    response = {
      success: success,
      message: message
    }
    response[:data] = data unless data.nil?
    response[:error] = error unless error.nil?
    
    json response
  end
end
