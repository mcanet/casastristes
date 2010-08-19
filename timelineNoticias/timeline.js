var oldFillInfoBubble = Timeline.DefaultEventSource.Event.prototype.fillInfoBubble;
Timeline.DefaultEventSource.Event.prototype.fillInfoBubble = function(elmt, theme, labeller) {
	oldFillInfoBubble.call(this, elmt, theme, labeller);

	var divTime = doc.createElement("div");  
	if (this.isInstant()) {  
		 divTime.appendChild(elmt.ownerDocument.createTextNode(labeller.labelPrecise(this.getStart())));  
	} else {  
		 divTime.appendChild(elmt.ownerDocument.createTextNode(labeller.labelPrecise(this.getStart())));  
		 divTime.appendChild(elmt.ownerDocument.createTextNode(" - "));  
		 divTime.appendChild(elmt.ownerDocument.createTextNode(labeller.labelPrecise(this.getEnd())));  
	}  
  elmt.appendChild(div);
}


var tl;
function onLoad() {
  var eventSource = new Timeline.DefaultEventSource();

  var theme = Timeline.ClassicTheme.create();
	theme.event.label.width = 300;
  theme.event.bubble.width = 400;
  theme.event.bubble.height = 250;

  var bandInfos = [
  Timeline.createBandInfo({
		eventSource:    eventSource,
    trackHeight:    1.7,
    date:           "Mar 31 2009",
    width:          "80%", 
    intervalUnit:   Timeline.DateTime.DAY, 
    intervalPixels: 60,
		theme:					theme
  }),
  Timeline.createBandInfo({
		showEventText:  false,
    trackHeight:    0.4,
    trackGap:       0.2,
		eventSource:    eventSource,
    date:           "Mar 31 2009",
    width:          "20%", 
    intervalUnit:   Timeline.DateTime.MONTH, 
    intervalPixels: 150,
		theme:					theme
  })
  ];
  bandInfos[1].syncWith = 0;
  bandInfos[1].highlight = true;
  bandInfos[1].eventPainter.setLayout(bandInfos[0].eventPainter.getLayout());

	for (var i = 0; i < bandInfos.length; i++) {
    bandInfos[i].decorators = [
      /*new Timeline.SpanHighlightDecorator({
          startDate:  "1300",
          endDate:    "1790",
          color:      "#FFC080",
          opacity:    50,
          startLabel: "bulla",
          endLabel:   "bulla",
          theme:      theme
      }),
      new Timeline.SpanHighlightDecorator({
          startDate:  "1790",
          endDate:    "2010",
          color:      "#FFC080",
          opacity:    50,
          startLabel: "patum",
          endLabel:   "patum",
          theme:      theme
      }),*/
      new Timeline.PointHighlightDecorator({
          date:       "Mar 31 2009",
          color:      "#FFC080",
          opacity:    50,
          theme:      theme
      })
  ];
}


  tl = Timeline.create(document.getElementById("timeline"), bandInfos);
  Timeline.loadXML("/sites/all/timeline/noticias.xml", function(xml, url) { eventSource.loadXML(xml, url); });
}

var resizeTimerID = null;
function onResize() {
    if (resizeTimerID == null) {
        resizeTimerID = window.setTimeout(function() {
            resizeTimerID = null;
            tl.layout();
        }, 500);
    }
}

function centerTimeline(date) {
    tl.getBand(0).setCenterVisibleDate(Timeline.DateTime.parseIso8601DateTime(date));
}


