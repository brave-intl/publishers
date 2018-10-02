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

  # exe_path: system('xvfb-run -a -s "-screen 0 640x480x16" /usr/bin/wkhtmltopdf "$@"')
  # You need to specify atleast one input file, and exactly one output file

  # exe_path: exec('xvfb-run -a -s "-screen 0 640x480x16" /usr/bin/wkhtmltopdf "$@"')
  # You need to specify atleast one input file, and exactly one output file
  
  #exe_path: '/usr/bin/wkhtmltopdf'
  # RuntimeError: Failed to execute:
  # ["/usr/bin/wkhtmltopdf", "-q", "file:////tmp/wicked_pdf20181002-21752-r9er7a.html", "/tmp/wicked_pdf_generated_file20181002-21752-1tue41i.pdf"]
  # Error: PDF could not be generated!
  #  Command Error: QXcbConnection: Could not connect to display 

  exe_path: Rails.root.join('bin/wkhtmltopdf-with-xvfb.sh').to_s #
  # RuntimeError: wkhtmltopdf is not executable

  # exe_path: exec(Rails.root.join('bin/wkhtmltopdf-with-xvfb.sh').to_s)
  # Errno::EACCES: Permission denied - /home/travis/build/brave-intl/publishers/bin/wkhtmltopdf-with-xvfb.sh
}
