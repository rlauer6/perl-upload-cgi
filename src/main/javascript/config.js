var debug = 1;

$(function() {
  
  const spinnerWrapperEl = document.querySelector('.spinner-wrapper');

  spinner_up(spinnerWrapperEl);
    
  const alert_placeholder = document.getElementById('alert-placeholder');

  const append_alert = (message, type) => {
    const wrapper = document.createElement('div')
    wrapper.innerHTML = [
      `<div class="alert alert-${type} alert-dismissible" role="alert">`,
      `   <div>${message}</div>`,
      '   <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>',
      '</div>'
    ].join('')
    
    alert_placeholder.append(wrapper)
  }
  
  // tooltips  
  const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
  const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))

  // toast
  const toaster  = bootstrap.Toast.getOrCreateInstance($("#toast-widget"))    
  
  logit("starting...");

  init_form(spinnerWrapperEl);
  
  $("#cancel-btn").on("click", function(e) {
    logit('cancel');
    
    e.preventDefault();

    spinner_up(spinnerWrapperEl);
    
    init_form(spinnerWrapperEl);
    
    return false;
  });

  $("#save-btn").on("click", function(e) {
    logit('saving...');

    e.preventDefault();

    $(this).prop("disabled", true);
    
    var config = {
      "redis": {},
      "upload" : {},
      "session" : {}
    };
    
    // Redis
    config.redis.port = $("#port").val();
    config.redis.timeout = $("#redis_timeout").val();
    config.redis.server = $("#server").val();

    // Upload
    config.upload.store_method = $("#store_method").val();
    config.upload.path = $("#path").val();
    config.upload.temp_dir = $("#temp_dir").val();
    config.upload.timeout = $("#timeout").val();
    config.upload.max_file_size= $("#max_file_size").val();
    
    if (  $("#metadata").is(":checked") ) {
      config.upload.metadata = "yes"
    }
    else {
      config.upload.metadata = "no"
    }

    if (  $("#fix_filename").is(":checked") ) {
      config.upload.fix_filename = "yes"
    }
    else {
      config.upload.fix_filename = "no"
    }

    // Cookie
    config.session.timeout = $("#session_timeout").val();
    config.session.cookie_name = $("#cookie_name").val();
    config.session.no_cookie_error = $("#no_cookie_error").val();
    
    $.ajax({
      url: '/upload/config',
      method: 'POST',
      data: JSON.stringify(config),
      contentType: "application/json; charset=utf-8",
      dataType: "json",
      success: function(data) {
        logit(data);

        append_alert("Successfully saved configuration!", "success");

        // toast
        toast_it(toaster, 'Successfully saved configuration!');
          
        $("#save-btn").prop("disabled", false);
      },
      error: function(data) {
        data = JSON.parse(data.responseText);

        append_alert(data.error, "danger");
        
        $("#save-btn").prop("disabled", false);
      }
    });
    
    return false;
  });
  
});    

function spinner_up(spinnerWrapperEl) {
  _spinner(spinnerWrapperEl, 'flex');
}

function spinner_down(spinnerWrapperEl) {
  _spinner(spinnerWrapperEl, 'none');
}
    
function _spinner(spinnerWrapperEl, display) {
    spinnerWrapperEl.style.opacity = '50%';
    spinnerWrapperEl.style.display = display;
}

function init_form(spinnerWrapperEl) {
  
  $.ajax({
    url: '/upload/config',
    dataType: 'json',
    success: function(data) {
      $("#upload-config").attr("action", data.template.config.url);
      
      // upload section
      $("#path").val(data.upload.path);
      $("#temp_dir").val(data.upload.temp_dir);
      $("#max_file_size").val(data.upload.max_file_size);
      $("#timeout").val(data.upload.timeout);
      
      if ( data.upload.fix_filename == "yes" ) {
        $("#fix_filename").prop('checked', true);
      }

      if ( data.upload.metadata == "yes" ) {
        $("#metadata").prop('checked', true);
      }
      
      $("#store_method").val(data.upload.store_method);

      // redis section
      $("#redis_timeout").val(data.redis.timeout);
      $("#port").val(data.redis.port);
      $("#server").val(data.redis.server);

      // session section
      $("#cookie_name").val(data.session.cookie_name);
      $("#session_timeout").val(data.session.timeout);
      $("#no_cookie_error").val(data.session.no_cookie_error);

      spinner_down(spinnerWrapperEl);
    },
    error: function(data) {
      logit(data);
    }
  });
}

function toast_it(toaster, message) {
   $('#toast-content').html(message);
   toaster.show();
}

function logit(message) {

  if (! debug ) {
    return;
  }
  
  console.log(message);
}
