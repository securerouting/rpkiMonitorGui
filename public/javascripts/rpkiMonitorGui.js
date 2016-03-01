function rpkiLoadFrames(fromurl, framesToUpdate, options) {
    var compiledSources = {};
    if (options && 'reloadIconId' in options) {
	$("." + options['reloadIconId']).css('visibility','visible');
    }
    $.ajax({
	url:  fromurl,
	type: 'GET',
	success: function(result) {
	    // note: not sure why this is getting on object instead of a string
	    // that needs to be passed to JSON.parse() first

	    for(var i = 0; i < framesToUpdate.length; i++) {
		var sourceid = framesToUpdate[i]['source'];
		var frameid = framesToUpdate[i]['frame'];
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

	    if (options && 'reloadIconId' in options) {
		$("." + options['reloadIconId']).css('visibility','hidden');
		console.log("hiding");
	    }
	},
	error: function() {
	    alert ("failed to load some data from the server");

	    if (options && 'reloadIconId' in options) {
		$("." + options['reloadIconId']).css('visibility','hidden');
	    }
	}
    });
}  

