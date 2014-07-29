function summarize_user_count_and_hours(subtree, what){
  return subtree.ct + " users who've spent a collective " + moment.duration(subtree.dt).humanize() + " found it " + what;
}

function total_time_string(data){
  var total_time = 0;
  if (data["tws:*"]) total_time += data["tws:*"].dt;
  if (data["suboptimal:*"]) total_time += data["suboptimal:*"].dt;
  return "No Regrets users have spent <b>" + moment.duration(total_time).humanize() +"</b> here. ";
}

function cute_summary_of_ratings(data){
  var findings = [];
  var str = '';

  if (data["tws:*"]) findings.push(summarize_user_count_and_hours(data["tws:*"], "time well spent"));
  if (data["suboptimal:*"]) findings.push(summarize_user_count_and_hours(data["suboptimal:*"], "suboptimal"));

  str += findings.join(' and ') + "<br>";
  if (data.top_wishes) str += "<br>Those that found it suboptimal wish they'd been: " + data.top_wishes.join(', ');
  return str;
}
