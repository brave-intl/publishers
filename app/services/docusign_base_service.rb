class DocusignBaseService
  private

  def docusign
    @docusign ||= DocusignRest::Client.new
  end

  def docusign_send(method_sym, **args)
    response = docusign.public_send(method_sym, **args)
    if error = response_error(response)
      raise error
    end
    response
  end

  def response_error(response)
    parsed_response =
      response.respond_to?(:body) \
      ? (JSON.try(:parse, response.body) || response.body) \
      : response
    if parsed_response["errorCode"]
      parsed_response["message"] || parsed_response["errorCode"]
    end
  end

  class TooManyRequestsError < RuntimeError
  end
end
