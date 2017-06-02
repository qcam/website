var timeEls = document.getElementsByTagName("time");
var formatDateTime = function(date) {
  var options = {
    weekday: "short",
    year: "numeric",
    month: "short",
    day: "numeric",
  };

  return date.toLocaleDateString("en-US", options);
};

for (var timeEl of Array.from(timeEls)) {
  var timeStr = timeEl.getAttribute("datetime");
  if (timeStr === null) {
    continue;
  } else {
    var time = new Date(Date.parse(timeStr));
    timeEl.innerHTML = formatDateTime(time);
  }
}
