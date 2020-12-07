// naming convention: object: name, function: $name, property: _name, event: __name
var doc = document;
var ce = chrome.extension;
var $elem = "getElementById";
var $make = "createElement";
var $bp = "getBackgroundPage";
var $setHide = "setHideText";
var $setUrl = "setUrl";
var $setOld = "setOld";
var _st = "style";
var _cls = "className";
var _val = "value";
var _txt = "innerText";
var _chk = "checked";
var __down, __up;

String.prototype.startsWith = function(str){
	return (this.indexOf(str) === 0);
}
var chromePages = {
	EMPTY: "about:blank",
	Apps: "chrome://apps/",
	Extensions: "chrome://extensions/",
	History: "chrome://history/",
	Downloads: "chrome://downloads/",
	Bookmarks: "chrome://bookmarks/",
	Internals: "chrome://net-internals"
}
var aboutPages = ["about:blank", "about:version", "about:plugins", "about:cache", "about:memory", "about:histograms", "about:dns", "about:terms", "about:credits", "about:net-internals"];

var popularPages = {
	"Google+": "plus.google.com",
	"Facebook": "www.facebook.com",
	"Twitter": "www.twitter.com",
	"Yahoo": "www.yahoo.com",
	"Wikipedia" : "www.wikipedia.org",
	"Digg": "www.digg.com",
	"Delicious": "www.delicious.com",
	"Slashdot": "www.slashdot.org"
};

// save options to localStorage.
function save_options(){
	var _url = doc[$elem]('custom-url');
	var url = _url[_val];
	//if (url == "") {
	//	url = aboutPages[0];
	//}

   save(true, url);
}

function save(good, url){
	clearTimeout(__up);
	clearTimeout(__down);
	var _sts = doc[$elem]('status');
	//var controller = ce[$bp]();
	var _hide = doc[$elem]('hidetext');
	var _old = doc[$elem]('old');
	
	if (good) {
		  chrome.storage.sync.set({
			url: encodeURI(url),
			hidetext: _hide.checked,
			old: _old.checked
		  });
		  setUrl(url);
	  _sts[_txt] = "Options Saved.";
	}
	else {
		_sts[_txt] = ("Invalid Url. Not saved.");
	}
	
	_sts[_st].display = "block";
	_sts[_cls] = "slideDown";
	__up = setTimeout(function(){
		clearTimeout(__down);
		_sts[_cls] = "slideUp";
		__down = setTimeout(function(){_sts[_cls] = ""; _sts[_st].display = "none";}, 2000);
	}, 3050);
}

function restore_options(){	
	chrome.storage.sync.get({
		url:      chrome.extension.getURL("options.html"),
		hidetext: true, 
		old:      false 
	}, function(options) {
		doc[$elem]('custom-url')[_val] = options.url;
		doc[$elem]('hidetext').checked =  options.hidetext;
		doc[$elem]('old').checked = options.old;
	});
}

function saveQuickLink(url){
	var uurl = unescape(url);
	  doc[$elem]('custom-url')[_val] = uurl;
	save(true, uurl);
	return false;
}

function ready(){	

	document.getElementById('save-button').onclick = save_options;
	document.getElementById('cancel-button').onclick = restore_options;

	restore_options();
	var _chromes = doc[$elem]('chromes');
	var _abouts = doc[$elem]('abouts');
	var _pops = doc[$elem]('popular');

	for (var key in chromePages) {
		var value = chromePages[key];
		var anchor = "<a href=\"#\">" + key + "</a>";
		var item = doc[$make]('li');
		item.innerHTML = anchor;
		item.firstChild.onclick = saveQuickLink.bind(item.firstChild, value);
		_chromes.appendChild(item);
	};
	
	for (var i = aboutPages.length - 1; i >= 0; i--){
		var $this = aboutPages[i];
		var anchor = "<a href=\"#\">" + $this + "</a>";
		var item = doc[$make]('li');
		item.innerHTML = anchor;
		item.firstChild.onclick = saveQuickLink.bind(item.firstChild, $this);
		_abouts.appendChild(item);
	};
	
	for (var key in popularPages) {
		var value = popularPages[key];
		var anchor = "<a href=\"#\">" + key + "</a>";
		var item = doc[$make]('li');
		item.innerHTML = anchor;
		item.firstChild.onclick = saveQuickLink.bind(item.firstChild, value);
		_pops.appendChild(item);
	};
}


String.prototype.startsWith = function (str) {
    return (this.indexOf(str) === 0);
}

var url = null;
var protocol = undefined;
var allowedProtocols = ["http://", "https://", "about:", "file://", "file:\\", "file:///", "chrome://", "chrome-extension://"];

function setUrl(url) {


    if (protocolPasses(url) && url.length > 8) {
        this.url = url;
    } else if (url) {
        protocol = 'http://';
        var right = url.split('://')
        if (right != undefined && right != null && right.length > 1) {
            this.url = protocol + right[1];
        } else {
            this.url = protocol + url;
        }
    }

    chrome.storage.sync.set({ url: this.url });
    
    function protocolPasses(url) {
        if (typeof(url) == 'undefined' || url == null) {
            return false;
        }
        if (url.startsWith(allowedProtocols[3]) && !url.startsWith(allowedProtocols[5])) {
            url.replace(allowedProtocols[3], allowedProtocols[5]);
        } else if (url.startsWith(allowedProtocols[4])) {
            url.replace(allowedProtocols[4], allowedProtocols[5]);
        }
        for (var p in allowedProtocols) {
            if (url.startsWith(allowedProtocols[p])) {
                return true;
            }
        }
        return false;
    }
}

window.onload = ready;
