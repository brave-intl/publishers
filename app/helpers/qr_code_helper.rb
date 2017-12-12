module QrCodeHelper
  require 'rqrcode'

  def qr_code_svg(data, size: 3)
    qr_code = RQRCode::QRCode.new(data)
    qr_code.as_svg(module_size: size)
  end
end
