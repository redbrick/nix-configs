{title, subtitle, message}: ''
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <title>${title}</title>
    <link
      href="//www.redbrick.dcu.ie/rb_custom_error/includes/error.css"
      rel="stylesheet"
      type="text/css"
    />
  </head>
  <body>
    <center>
      <div id="container">
        <div id="main">
          <h1>${title}</h1>
          <h2>${subtitle}</h2>
          <p> ${message} </p>
          <p>
            If you think this is a server error, please contact the
            <a href="mailto:webmaster@redbrick.dcu.ie">webmaster</a>.
          </p>
          <div class="logo">
            <img
              src="//www.redbrick.dcu.ie/rb_custom_error/includes/rb.png"
              alt="Redrick Logo"
            />
          </div>
          <div class="clear">&nbsp;</div>
        </div>
      </div>
    </center>
  </body>
</html>
''
