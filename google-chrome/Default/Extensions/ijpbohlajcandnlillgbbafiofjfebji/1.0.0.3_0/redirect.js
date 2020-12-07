chrome.storage.sync.get("url", function(options) {
	if (typeof options.url == "undefined")
		options.url = chrome.extension.getURL("options.html");
	if ((/^http:/i.test(options.url)) || /^https:/i.test(options.url)) {
		document.location.href = options.url;
		return;
	} 
	if (options.url == "about:blank") {
		return;
	}
	chrome.tabs.getCurrent(function(t) {		
		chrome.tabs.update(t.id, {
			"url":  options.url,
			"selected": true
		});
	});
});
