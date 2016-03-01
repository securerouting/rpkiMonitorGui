var source = jQuery("#rpki-rtr-client-monitor-data").html();
var template = Handlebars.compile(source);

function rpkiLoadFrames(fromurl, framesToUpdate) {
    var compiledSources = {};
    $.ajax({
	url:  fromurl,
	type: 'GET',
	success: function(result) {
	    // note: not sure why this is getting on object instead of a string
	    // that needs to be passed to JSON.parse() first

	    for(var i = 0; i < framesToUpdate.length; i++) {
		var sourceid = framesToUpdate[i][0];
		var frameid = framesToUpdate[i][1];
		var sourceFrame = $("#" + sourceid).html();
		if (! sourceFrame) {
		    alert("error in web page ; see console for technical details");
		    alert("failed to get the source frame for " + sourceid);
		    return;
		}
		compiledSources[sourceid] = Handlebars.compile(sourceFrame);
		
		if (! compiledSources[sourceid]) {
		    alert("failed to load some information from the server");
		    console.log("handlebars failed to compile");
		}

		var htmlOutput = compiledSources[sourceid](result);
		
		if (htmlOutput) {
		    $('#' + frameid).html(htmlOutput);
		} else {
		    alert("failed to decode some data from the server");
		}
	    }
	},
	error: function() {
	    alert ("failed to load some data from the server");
	}
    });
}  

