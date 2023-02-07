var files_uploaded = 0;
var intervalId;
var file_list = [];
var upload_time = 0;

$(function() {

  console.log("starting...");

  $("#clear-btn").on("click", function(e) {
    e.preventDefault();

    clear_uploads();

    $("#upload").val("");
    
    $("#upload-btn").attr("disabled", true);

    return false;
  });

  $("#upload").on("change", function() {
    var files = $("#upload")[0].files;

    clear_uploads();
   
    if ( files.length ) {
      $(files).each(function(i, file) {

        file_list.push({
          filename : file.name,
          size : file.size,
          type : file.type,
          index : i
          });
      });

      init_upload(file_list);
    }
    else {
      $("#upload-btn").attr("disabled", true);
    }
  });
    
  $("#upload-btn").attr("disabled", true);
  
  $("#upload-btn").on("click", function(e) {
    e.preventDefault();

    var files = $("#upload")[0].files;
    
    if ( ! files.length ) {
      $("#upload-btn").attr("disabled", true);

      return;
    }

    $("#upload").submit();

    return false;
  });

  $("#upload-form").on("submit", function(e) {
    e.preventDefault();
    
    $('#upload-btn').attr('disabled', 'true');

    var files = $("#upload")[0].files;
    
    // submit each form separately
    $.each(files, function(i, file) {
      var data = new FormData();

      data.append("filename", file);
      data.append("index", i);
            
      $.ajax({
        url: "/cgi-bin/upload.cgi",
        method: "POST",
        type: "POST",
        contentType: false,
        processData: false,
        cache: false,
        data: data,
        success: function(data) {
          var file_info = data;
          
          var index = file_info.index;
          
          files_uploaded++;

          $("#progress-" + index).removeClass('progress-bar-striped');
          $("#progress-" + index).removeClass('progress-bar-animated');

          var file_completion_percent = Math.floor(100 * files_uploaded/files.length);

          update_progress_bar('progress-all-files', file_completion_percent);
          
          var elapsed_time = parseFloat(file_info.elapsed_time_formatted);
          
          if ( elapsed_time  > upload_time ) {
            upload_time = elapsed_time;
          }
              
          if ( files_uploaded  >= file_list.length ) {
            intervalId = clearInterval(intervalId);
            var num_uploaded = files_uploaded;    
            files_uploaded = 0;
            file_list = [];
            
            $("#progress-status").html( num_uploaded + " files uploaded in " + upload_time + " seconds");
            
            $("#progress-status").css("font-weight", "600");

            upload_time = 0;

            $("#progress-all-files").removeClass('progress-bar-striped');
            $("#progress-all-files").removeClass('progress-bar-animated');

          }
          else {
            $("#progress-status").html("Uploaded " + files_uploaded + " of " + file_list.length);
          }
        },
        error: function(data)  {
          clearInterval(intervalId);
          alert("upload aborted");
        }
      });
    });
    
    intervalId = setInterval(get_upload_progress, 100, files);
  });

});

// clear upload list and status
function clear_uploads() {

  file_list = [];
  
  //remove progress bars and filenames
  $(".progress").remove();
  $(".progress-filename").remove();

  // reset status chyron
  $("#progress-status").html("");
  $("#progress-status").css("font-weight", "normal");
  
}

// fetch upload progress
function get_upload_progress(files) {
  
  var session_id = getCookie("SessionID");

  $.ajax({
    url: "/cgi-bin/upload.cgi",
    method: "GET",
    type: "GET",
    data: {
      action : "fetch-status",
      session_id : session_id
    },
    success: function(data) {
      var files;

      // timeout?
      if ( data && data.error ) {
        alert(data.error);

        if ( intervalId ) {
          clearInterval(intervalId);
        }
        
        return;
      }
      else {
        files = data.files;
      }

      $.each(files, function(name, file_info) {

        var filename = name;
        var id = file_info.index
        var percent_complete = file_info.percent_complete || "0";
        
        update_progress_bar('progress-' + id, percent_complete);
      });

    }
  });
}

function update_progress_bar(id, percent_complete) {
  $("#" + id).attr("aria-valuenow", percent_complete);
  $("#" + id).css("width", percent_complete + "%");
  $("#" + id).html(percent_complete + "%");
}

// create a progress bar
function create_progress_bar(id, container, extra_class, height) {

  if ( ! height ) {
    height = "20";
  }

  var classes = ["progress-bar"];

  if ( extra_class ) {
      if (Array.isArray(extra_class)) {
          $.each(extra_class, function(i, item) {
              classes.push(item);
          });
      }
      else {
          classes.push(extra_class);
      }
  }

  // <div class="progress">
  var div = document.createElement("div");
  $(div).attr("class", "progress w-75");
  $(div).css({ "margin-bottom" : "10px", "height" : height + "px" });
  
  $("#" + container).append(div);
  
  // <div class="progress-bar">
  var progress_div = document.createElement("div");
  $(progress_div).attr({
        id : id,
        "class" : classes.join(" "),
        role : "progressbar",
        "aria-valuenow" : "0",
        "aria-valuemin" : "0",
        "aria-valuemax" : "100"        
      });

  $(div).append(progress_div);
  
  return div;
}

// create progress bar for each file
function create_progress_bar_set(file_list) {
  
  $(file_list).each(function(i, file) {
    
    // create a progress div if it does not already exist
    var id = "progress-" + i
    var index = i + 1;
    
    if ( ! $("#" + id).length ) {

      // filename
      var filename_div = document.createElement("div");
      $(filename_div).css({"font-size" : ".75em", "font-style" : "italic"});
      $(filename_div).html("[" + index + "] " + file.filename + " (" + file.size + ")");
      $(filename_div).attr({ id :  "progress-filename-" + i, "class" : "progress-filename"});

      $("#progress-container").append(filename_div);

      create_progress_bar(id, "progress-container", ["bg-success", "progress-bar-striped" , "progress-bar-animated"]);
    }
  });

  var classes = ["bg-info progress-bar-striped progress-bar-animated"];
  var elem = create_progress_bar("progress-all-files", "progress-container", classes, 40);
  $(elem).css({ "margin-top": "25px", "margin-bottom" : "5px"});
  
  $("#progress-status").html(file_list.length + " files to upload");
}

// inititalize upload
function init_upload (file_list) {
  
  var data = {
    action : "initialize-upload",
    file_list : JSON.stringify(file_list)
  };

  $.ajax(
    {
      method: "GET",
      url: "/cgi-bin/upload.cgi",
      data: data,
      success: function (data) {
        $("#upload-btn").attr("disabled", false);
        
        $.each(data, function(i, info) {
          file_list[info.index].size = info.size_human;
        });

        create_progress_bar_set(file_list);
      },
      error: function (data) {
        alert("Error initialing upload");
      }
    }
  );

  return true;
}

// cookie getter
function getCookie(cname) {
  
  var name = cname + "=";
  var decodedCookie = decodeURIComponent(document.cookie);
  var ca = decodedCookie.split(";");
  
  for (i = 0; i <ca.length; i++) {
    var c = ca[i];
    
    while (c.charAt(0) == " ") {
      c = c.substring(1);
    }

    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }

  return "";
}
