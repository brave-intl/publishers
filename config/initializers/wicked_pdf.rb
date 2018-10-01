# WickedPDF Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# models by passing arguments to the `render :pdf` call.
#
# To learn more, check out the README:
#
# https://github.com/mileszs/wicked_pdf/blob/master/README.md

WickedPdf.config = {
  # We install the binary with heroku-buildpack-apt
  # https://elements.heroku.com/buildpacks/heroku/heroku-buildpack-apt (see Aptfile)
  exe_path: Rails.root.join('bin/wkhtmltopdf-with-xvfb.sh').to_s
}
