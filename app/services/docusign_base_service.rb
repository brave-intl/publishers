class DocusignBaseService
  private

  def docusign
    @docusign ||= DocusignRest::Client.new
  end

  def docusign_send(method_sym, **args)
    response = docusign.public_send(method_sym, **args)
    raise response["message"] if response["message"] && response["errorCode"]
    response
  end
end
