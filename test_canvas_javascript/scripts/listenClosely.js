
function logEventInfo (ev) {
  log.innerHTML = '';
  out = '<ul>';
  for (var i in ev) {
    if (typeof ev[i] === 'function' || i === i.toUpperCase()) {
      continue;
    }
    out += '<li><span>'+i+'</span>: '+ev[i]+'</li>';
  }
  log.innerHTML += out + '</ul>';
}


function logLessEventInfo (ev) {
  log.innerHTML = '';
  out = '<ul>';

  out += '<li><span>type</span>: '+ev['type']+'</li>';
  out += '<li><span>which</span>: '+ev['which']+'</li>';
  out += '<li><span>target</span>: '+ev['target']+'</li>';
  out += '<li><span>currentTarget</span>: '+ev['currentTarget']+'</li>';
  out += '<li><span>timeStamp</span>: '+ev['timeStamp']+'</li>';
  out += '<li></li>';
  out += '<li><span>charCode</span>: '+ev['charCode']+'</li>';
  out += '<li><span>keyCode</span>: '+ev['keyCode']+'</li>';
  out += '<li><span>keyIdentifier</span>: '+ev['keyIdentifier']+'</li>';
  out += '<li><span>altKey</span>: '+ev['altKey']+'</li>';
  out += '<li><span>shiftKey</span>: '+ev['shiftKey']+'</li>';
  out += '<li><span>ctrlKey</span>: '+ev['ctrlKey']+'</li>';
  out += '<li><span>metaKey</span>: '+ev['metaKey']+'</li>';
  out += '<li><span>altGraphKey</span>: '+ev['altGraphKey']+'</li>';
 out += '</ul>';
out += '<table>'
out += '<tr><td></td> <td>&emsp;x&emsp;</td> <td>&emsp;y&emsp;</td></tr>'
out += '<tr><td></td> <td>'+ev['x']+'</td> <td>'+ev['y']+'</td> </tr>'
out += '<tr><td>screen&emsp;</td> <td>'+ev['screenX']+'</td> <td>'+ev['screenY']+'</td> </tr>'
out += '<tr><td>layer&emsp;</td> <td>'+ev['layerX']+'</td> <td>'+ev['layerY']+'</td> </tr>'
out += '<tr><td>client&emsp;</td> <td>'+ev['clientX']+'</td> <td>'+ev['clientY']+'</td> </tr>'
out += '</table>'
  log.innerHTML = out;
}


function listenClosely (){
	stopListening ();

	document.addEventListener('mouseenter', logEventInfo, false);
	document.addEventListener('mouseleave', logEventInfo, false);
	document.addEventListener('afterprint', logEventInfo, false);
	document.addEventListener('beforeprint', logEventInfo, false);
	document.addEventListener('beforeunload', logEventInfo, false);
	document.addEventListener('hashchange', logEventInfo, false);
	document.addEventListener('message', logEventInfo, false);
	document.addEventListener('offline', logEventInfo, false);
	document.addEventListener('online', logEventInfo, false);
	document.addEventListener('popstate', logEventInfo, false);
	document.addEventListener('pagehide', logEventInfo, false);
	document.addEventListener('pageshow', logEventInfo, false);
	document.addEventListener('resize', logEventInfo, false);
	document.addEventListener('unload', logEventInfo, false);
	document.addEventListener('devicemotion', logEventInfo, false);
	document.addEventListener('deviceorientation', logEventInfo, false);
	document.addEventListener('abort', logEventInfo, false);
	document.addEventListener('blur', logEventInfo, false);
	document.addEventListener('canplay', logEventInfo, false);
	document.addEventListener('canplaythrough', logEventInfo, false);
	document.addEventListener('change', logEventInfo, false);
	document.addEventListener('click', logEventInfo, false);
	document.addEventListener('contextmenu', logEventInfo, false);
	document.addEventListener('dblclick', logEventInfo, false);
	document.addEventListener('drag', logEventInfo, false);
	document.addEventListener('dragend', logEventInfo, false);
	document.addEventListener('dragenter', logEventInfo, false);
	document.addEventListener('dragleave', logEventInfo, false);
	document.addEventListener('dragover', logEventInfo, false);
	document.addEventListener('dragstart', logEventInfo, false);
	document.addEventListener('drop', logEventInfo, false);
	document.addEventListener('durationchange', logEventInfo, false);
	document.addEventListener('emptied', logEventInfo, false);
	document.addEventListener('ended', logEventInfo, false);
	document.addEventListener('error', logEventInfo, false);
	document.addEventListener('focus', logEventInfo, false);
	document.addEventListener('input', logEventInfo, false);
	document.addEventListener('invalid', logEventInfo, false);
	document.addEventListener('keydown', logEventInfo, false);
	document.addEventListener('keypress', logEventInfo, false);
	document.addEventListener('keyup', logEventInfo, false);
	document.addEventListener('load', logEventInfo, false);
	document.addEventListener('loadeddata', logEventInfo, false);
	document.addEventListener('loadedmetadata', logEventInfo, false);
	document.addEventListener('loadstart', logEventInfo, false);
	document.addEventListener('mousedown', logEventInfo, false);
	document.addEventListener('mousemove', logEventInfo, false);
	document.addEventListener('mouseout', logEventInfo, false);
	document.addEventListener('mouseover', logEventInfo, false);
	document.addEventListener('mouseup', logEventInfo, false);
	document.addEventListener('mozfullscreenchange', logEventInfo, false);
	document.addEventListener('mozfullscreenerror', logEventInfo, false);
	document.addEventListener('pause', logEventInfo, false);
	document.addEventListener('play', logEventInfo, false);
	document.addEventListener('playing', logEventInfo, false);
	document.addEventListener('progress', logEventInfo, false);
	document.addEventListener('ratechange', logEventInfo, false);
	document.addEventListener('reset', logEventInfo, false);
	document.addEventListener('scroll', logEventInfo, false);
	document.addEventListener('seeked', logEventInfo, false);
	document.addEventListener('seeking', logEventInfo, false);
	document.addEventListener('select', logEventInfo, false);
	document.addEventListener('show', logEventInfo, false);
	document.addEventListener('stalled', logEventInfo, false);
	document.addEventListener('submit', logEventInfo, false);
	document.addEventListener('suspend', logEventInfo, false);
	document.addEventListener('timeupdate', logEventInfo, false);
	document.addEventListener('volumechange', logEventInfo, false);
	document.addEventListener('waiting', logEventInfo, false);
	document.addEventListener('copy', logEventInfo, false);
	document.addEventListener('cut', logEventInfo, false);
	document.addEventListener('paste', logEventInfo, false);
	document.addEventListener('beforescriptexecute', logEventInfo, false);
	document.addEventListener('afterscriptexecute', logEventInfo, false);

}




function listenPartially (){
	stopListening ();
	document.addEventListener('mouseenter', logLessEventInfo, false);
	document.addEventListener('mouseleave', logLessEventInfo, false);
	document.addEventListener('afterprint', logLessEventInfo, false);
	document.addEventListener('beforeprint', logLessEventInfo, false);
	document.addEventListener('beforeunload', logLessEventInfo, false);
	document.addEventListener('hashchange', logLessEventInfo, false);
	document.addEventListener('message', logLessEventInfo, false);
	document.addEventListener('offline', logLessEventInfo, false);
	document.addEventListener('online', logLessEventInfo, false);
	document.addEventListener('popstate', logLessEventInfo, false);
	document.addEventListener('pagehide', logLessEventInfo, false);
	document.addEventListener('pageshow', logLessEventInfo, false);
	document.addEventListener('resize', logLessEventInfo, false);
	document.addEventListener('unload', logLessEventInfo, false);
	document.addEventListener('devicemotion', logLessEventInfo, false);
	document.addEventListener('deviceorientation', logLessEventInfo, false);
	document.addEventListener('abort', logLessEventInfo, false);
	document.addEventListener('blur', logLessEventInfo, false);
	document.addEventListener('canplay', logLessEventInfo, false);
	document.addEventListener('canplaythrough', logLessEventInfo, false);
	document.addEventListener('change', logLessEventInfo, false);
	document.addEventListener('click', logLessEventInfo, false);
	document.addEventListener('contextmenu', logLessEventInfo, false);
	document.addEventListener('dblclick', logLessEventInfo, false);
	document.addEventListener('drag', logLessEventInfo, false);
	document.addEventListener('dragend', logLessEventInfo, false);
	document.addEventListener('dragenter', logLessEventInfo, false);
	document.addEventListener('dragleave', logLessEventInfo, false);
	document.addEventListener('dragover', logLessEventInfo, false);
	document.addEventListener('dragstart', logLessEventInfo, false);
	document.addEventListener('drop', logLessEventInfo, false);
	document.addEventListener('durationchange', logLessEventInfo, false);
	document.addEventListener('emptied', logLessEventInfo, false);
	document.addEventListener('ended', logLessEventInfo, false);
	document.addEventListener('error', logLessEventInfo, false);
	document.addEventListener('focus', logLessEventInfo, false);
	document.addEventListener('input', logLessEventInfo, false);
	document.addEventListener('invalid', logLessEventInfo, false);
	document.addEventListener('keydown', logLessEventInfo, false);
	document.addEventListener('keypress', logLessEventInfo, false);
	document.addEventListener('keyup', logLessEventInfo, false);
	document.addEventListener('load', logLessEventInfo, false);
	document.addEventListener('loadeddata', logLessEventInfo, false);
	document.addEventListener('loadedmetadata', logLessEventInfo, false);
	document.addEventListener('loadstart', logLessEventInfo, false);
	document.addEventListener('mousedown', logLessEventInfo, false);
	document.addEventListener('mousemove', logLessEventInfo, false);
	document.addEventListener('mouseout', logLessEventInfo, false);
	document.addEventListener('mouseover', logLessEventInfo, false);
	document.addEventListener('mouseup', logLessEventInfo, false);
	document.addEventListener('mozfullscreenchange', logLessEventInfo, false);
	document.addEventListener('mozfullscreenerror', logLessEventInfo, false);
	document.addEventListener('pause', logLessEventInfo, false);
	document.addEventListener('play', logLessEventInfo, false);
	document.addEventListener('playing', logLessEventInfo, false);
	document.addEventListener('progress', logLessEventInfo, false);
	document.addEventListener('ratechange', logLessEventInfo, false);
	document.addEventListener('reset', logLessEventInfo, false);
	document.addEventListener('scroll', logLessEventInfo, false);
	document.addEventListener('seeked', logLessEventInfo, false);
	document.addEventListener('seeking', logLessEventInfo, false);
	document.addEventListener('select', logLessEventInfo, false);
	document.addEventListener('show', logLessEventInfo, false);
	document.addEventListener('stalled', logLessEventInfo, false);
	document.addEventListener('submit', logLessEventInfo, false);
	document.addEventListener('suspend', logLessEventInfo, false);
	document.addEventListener('timeupdate', logLessEventInfo, false);
	document.addEventListener('volumechange', logLessEventInfo, false);
	document.addEventListener('waiting', logLessEventInfo, false);
	document.addEventListener('copy', logLessEventInfo, false);
	document.addEventListener('cut', logLessEventInfo, false);
	document.addEventListener('paste', logLessEventInfo, false);
	document.addEventListener('beforescriptexecute', logLessEventInfo, false);
	document.addEventListener('afterscriptexecute', logLessEventInfo, false);
}



function stopListening (){
	document.removeEventListener('mouseenter', logEventInfo, false);
	document.removeEventListener('mouseleave', logEventInfo, false);
	document.removeEventListener('afterprint', logEventInfo, false);
	document.removeEventListener('beforeprint', logEventInfo, false);
	document.removeEventListener('beforeunload', logEventInfo, false);
	document.removeEventListener('hashchange', logEventInfo, false);
	document.removeEventListener('message', logEventInfo, false);
	document.removeEventListener('offline', logEventInfo, false);
	document.removeEventListener('online', logEventInfo, false);
	document.removeEventListener('popstate', logEventInfo, false);
	document.removeEventListener('pagehide', logEventInfo, false);
	document.removeEventListener('pageshow', logEventInfo, false);
	document.removeEventListener('resize', logEventInfo, false);
	document.removeEventListener('unload', logEventInfo, false);
	document.removeEventListener('devicemotion', logEventInfo, false);
	document.removeEventListener('deviceorientation', logEventInfo, false);
	document.removeEventListener('abort', logEventInfo, false);
	document.removeEventListener('blur', logEventInfo, false);
	document.removeEventListener('canplay', logEventInfo, false);
	document.removeEventListener('canplaythrough', logEventInfo, false);
	document.removeEventListener('change', logEventInfo, false);
	document.removeEventListener('click', logEventInfo, false);
	document.removeEventListener('contextmenu', logEventInfo, false);
	document.removeEventListener('dblclick', logEventInfo, false);
	document.removeEventListener('drag', logEventInfo, false);
	document.removeEventListener('dragend', logEventInfo, false);
	document.removeEventListener('dragenter', logEventInfo, false);
	document.removeEventListener('dragleave', logEventInfo, false);
	document.removeEventListener('dragover', logEventInfo, false);
	document.removeEventListener('dragstart', logEventInfo, false);
	document.removeEventListener('drop', logEventInfo, false);
	document.removeEventListener('durationchange', logEventInfo, false);
	document.removeEventListener('emptied', logEventInfo, false);
	document.removeEventListener('ended', logEventInfo, false);
	document.removeEventListener('error', logEventInfo, false);
	document.removeEventListener('focus', logEventInfo, false);
	document.removeEventListener('input', logEventInfo, false);
	document.removeEventListener('invalid', logEventInfo, false);
	document.removeEventListener('keydown', logEventInfo, false);
	document.removeEventListener('keypress', logEventInfo, false);
	document.removeEventListener('keyup', logEventInfo, false);
	document.removeEventListener('load', logEventInfo, false);
	document.removeEventListener('loadeddata', logEventInfo, false);
	document.removeEventListener('loadedmetadata', logEventInfo, false);
	document.removeEventListener('loadstart', logEventInfo, false);
	document.removeEventListener('mousedown', logEventInfo, false);
	document.removeEventListener('mousemove', logEventInfo, false);
	document.removeEventListener('mouseout', logEventInfo, false);
	document.removeEventListener('mouseover', logEventInfo, false);
	document.removeEventListener('mouseup', logEventInfo, false);
	document.removeEventListener('mozfullscreenchange', logEventInfo, false);
	document.removeEventListener('mozfullscreenerror', logEventInfo, false);
	document.removeEventListener('pause', logEventInfo, false);
	document.removeEventListener('play', logEventInfo, false);
	document.removeEventListener('playing', logEventInfo, false);
	document.removeEventListener('progress', logEventInfo, false);
	document.removeEventListener('ratechange', logEventInfo, false);
	document.removeEventListener('reset', logEventInfo, false);
	document.removeEventListener('scroll', logEventInfo, false);
	document.removeEventListener('seeked', logEventInfo, false);
	document.removeEventListener('seeking', logEventInfo, false);
	document.removeEventListener('select', logEventInfo, false);
	document.removeEventListener('show', logEventInfo, false);
	document.removeEventListener('stalled', logEventInfo, false);
	document.removeEventListener('submit', logEventInfo, false);
	document.removeEventListener('suspend', logEventInfo, false);
	document.removeEventListener('timeupdate', logEventInfo, false);
	document.removeEventListener('volumechange', logEventInfo, false);
	document.removeEventListener('waiting', logEventInfo, false);
	document.removeEventListener('copy', logEventInfo, false);
	document.removeEventListener('cut', logEventInfo, false);
	document.removeEventListener('paste', logEventInfo, false);
	document.removeEventListener('beforescriptexecute', logEventInfo, false);
	document.removeEventListener('afterscriptexecute', logEventInfo, false);



	document.removeEventListener('mouseenter', logLessEventInfo, false);
	document.removeEventListener('mouseleave', logLessEventInfo, false);
	document.removeEventListener('afterprint', logLessEventInfo, false);
	document.removeEventListener('beforeprint', logLessEventInfo, false);
	document.removeEventListener('beforeunload', logLessEventInfo, false);
	document.removeEventListener('hashchange', logLessEventInfo, false);
	document.removeEventListener('message', logLessEventInfo, false);
	document.removeEventListener('offline', logLessEventInfo, false);
	document.removeEventListener('online', logLessEventInfo, false);
	document.removeEventListener('popstate', logLessEventInfo, false);
	document.removeEventListener('pagehide', logLessEventInfo, false);
	document.removeEventListener('pageshow', logLessEventInfo, false);
	document.removeEventListener('resize', logLessEventInfo, false);
	document.removeEventListener('unload', logLessEventInfo, false);
	document.removeEventListener('devicemotion', logLessEventInfo, false);
	document.removeEventListener('deviceorientation', logLessEventInfo, false);
	document.removeEventListener('abort', logLessEventInfo, false);
	document.removeEventListener('blur', logLessEventInfo, false);
	document.removeEventListener('canplay', logLessEventInfo, false);
	document.removeEventListener('canplaythrough', logLessEventInfo, false);
	document.removeEventListener('change', logLessEventInfo, false);
	document.removeEventListener('click', logLessEventInfo, false);
	document.removeEventListener('contextmenu', logLessEventInfo, false);
	document.removeEventListener('dblclick', logLessEventInfo, false);
	document.removeEventListener('drag', logLessEventInfo, false);
	document.removeEventListener('dragend', logLessEventInfo, false);
	document.removeEventListener('dragenter', logLessEventInfo, false);
	document.removeEventListener('dragleave', logLessEventInfo, false);
	document.removeEventListener('dragover', logLessEventInfo, false);
	document.removeEventListener('dragstart', logLessEventInfo, false);
	document.removeEventListener('drop', logLessEventInfo, false);
	document.removeEventListener('durationchange', logLessEventInfo, false);
	document.removeEventListener('emptied', logLessEventInfo, false);
	document.removeEventListener('ended', logLessEventInfo, false);
	document.removeEventListener('error', logLessEventInfo, false);
	document.removeEventListener('focus', logLessEventInfo, false);
	document.removeEventListener('input', logLessEventInfo, false);
	document.removeEventListener('invalid', logLessEventInfo, false);
	document.removeEventListener('keydown', logLessEventInfo, false);
	document.removeEventListener('keypress', logLessEventInfo, false);
	document.removeEventListener('keyup', logLessEventInfo, false);
	document.removeEventListener('load', logLessEventInfo, false);
	document.removeEventListener('loadeddata', logLessEventInfo, false);
	document.removeEventListener('loadedmetadata', logLessEventInfo, false);
	document.removeEventListener('loadstart', logLessEventInfo, false);
	document.removeEventListener('mousedown', logLessEventInfo, false);
	document.removeEventListener('mousemove', logLessEventInfo, false);
	document.removeEventListener('mouseout', logLessEventInfo, false);
	document.removeEventListener('mouseover', logLessEventInfo, false);
	document.removeEventListener('mouseup', logLessEventInfo, false);
	document.removeEventListener('mozfullscreenchange', logLessEventInfo, false);
	document.removeEventListener('mozfullscreenerror', logLessEventInfo, false);
	document.removeEventListener('pause', logLessEventInfo, false);
	document.removeEventListener('play', logLessEventInfo, false);
	document.removeEventListener('playing', logLessEventInfo, false);
	document.removeEventListener('progress', logLessEventInfo, false);
	document.removeEventListener('ratechange', logLessEventInfo, false);
	document.removeEventListener('reset', logLessEventInfo, false);
	document.removeEventListener('scroll', logLessEventInfo, false);
	document.removeEventListener('seeked', logLessEventInfo, false);
	document.removeEventListener('seeking', logLessEventInfo, false);
	document.removeEventListener('select', logLessEventInfo, false);
	document.removeEventListener('show', logLessEventInfo, false);
	document.removeEventListener('stalled', logLessEventInfo, false);
	document.removeEventListener('submit', logLessEventInfo, false);
	document.removeEventListener('suspend', logLessEventInfo, false);
	document.removeEventListener('timeupdate', logLessEventInfo, false);
	document.removeEventListener('volumechange', logLessEventInfo, false);
	document.removeEventListener('waiting', logLessEventInfo, false);
	document.removeEventListener('copy', logLessEventInfo, false);
	document.removeEventListener('cut', logLessEventInfo, false);
	document.removeEventListener('paste', logLessEventInfo, false);
	document.removeEventListener('beforescriptexecute', logLessEventInfo, false);
	document.removeEventListener('afterscriptexecute', logLessEventInfo, false);

	log.innerHTML = '';
}
