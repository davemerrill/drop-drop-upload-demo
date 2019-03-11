<cfscript>
	msg = "";
	if (!structIsEmpty(form))
	{
		path = getDirectoryFromPath(getCurrentTemplatePath()) & form.fileName;
		if (!fileExists(path))
		{
			content = form.fileContent;
			pos = Find('base64,', content);
			content = removeChars(content, 1, pos + 6);
			fileWrite(path, toBinary(content));
			msg = "File uploaded: #form.fileName#";
		}
		else
			msg = "File '#form.fileName# already exists, upload concelled.";
	}
</cfscript>

<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
	<title>Drag-Drop Upload Demo</title>
	<META http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<style type="text/css">
		body {width: 800px;}
		##msg {margin: 10px 0; color: red; font-weight: bold;}
		##drop-target {height: 100px; border: 1px solid ##ccc;}
		.drop-target-active {background-color: ##dfd;}
		input, textarea, label {display: block; width: 100%}
		label {margin-top: 1em;}
	</style>
</head>
<body>
	<h1>Drag-Drop Upload Demo</h1>

	<cfif msg neq "">
		<div id="msg">#htmlEditFormat(msg)#</div>
	</cfif>

	<form action="#cgi.script_name#" method="POST" enctype="multipart/form-data">
		Drop ONE file here
		<div id="drop-target"></div>
		<label for="fileName">File name</label>
		<input type="text" id="fileName" name="fileName">
		<label for="fileContent">File content</label>
		<textarea id="fileContent" name="fileContent" rows="10" cols="80"></textarea>
		<button type="submit">Upload File</button>
	</form>

	<script>
		dropTargetInit('drop-target', true, dropHandler);
		
		function dropTargetInit(targetID)
		{
			var ACTIVE_CLASS = 'drop-target-active';
			var timeoutID;
			addEvent(targetID, 'dragenter', function(event)
			{
				stopEvent(event);
				addRemoveClass(targetID, ACTIVE_CLASS, true);
			});
			addEvent(targetID, 'dragleave', function(event)
			{
				stopEvent(event);
				addRemoveClass(targetID, ACTIVE_CLASS, false);
				if (timeoutID)
					clearTimeout(timeoutID);
			});
			addEvent(targetID, 'dragover', function(event)
			{
				stopEvent(event);
				if (timeoutID)
					clearTimeout(timeoutID);
				timeoutID = setTimeout(function() // handles dragging off the window w/o dragging off the drop targetID; ff6 needs this, maybe others, or activeClass sticks
				{
					timeoutID = null;
					addRemoveClass(targetID, ACTIVE_CLASS, false);
				}, 100);
			});
			addEvent(targetID, 'drop', function(event)
			{
				stopEvent(event);
				addRemoveClass(targetID, ACTIVE_CLASS, false);
				dropHandler(event);
			});
		}

		function dropHandler()
		{
			var files = event.dataTransfer.files;
			if (!files || files.length < 1)
			{
				alert('Drop files here to upload them.');
				return;
			}
			for (var i = 0; i < files.length; i++)
				handleFile(files[i]);

			function handleFile(file)
			{
				var reader = new FileReader();
				reader.onloadend = function()
				{
					document.getElementById('fileName').value = htmlEncode(file.name);
					document.getElementById('fileContent').value = htmlEncode(reader.result);
				};
				reader.readAsDataURL(file);
			}
		}
		function htmlEncode(str)
		{
			return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
		}
		function addRemoveClass(objID, className, add)
		{
			var obj = document.getElementById(objID);
			obj.className = add ? className : '';
		}
		function stopEvent(event)
		{
			event.preventDefault();
			event.stopPropagation();
		}
		function addEvent(objID, types, fn)
		{
			obj = document.getElementById(objID);
			types = types.split(',');
			var type, i;
			for (i = 0; i < types.length; i++)
			{
				type = types[i];
				obj.addEventListener(type, fn, false);
			}
		}
	</script>
</body>
</html>
</cfoutput>