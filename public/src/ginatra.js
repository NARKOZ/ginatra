$(document).ready(function (){
  $(".commit-info tr:first-child td").addClass("first-no-border"); 
  $(".commit-author tr:first-child td").addClass("first-no-border"); 
  $(".commit-committer tr:first-child td").addClass("first-no-border"); 
  $(".commit-files tr:first-child td").addClass("first-no-border"); 
  $(".commit-log tr:first-child td").addClass("first-no-border"); 
  $(".repo-list dl dt:first-child").addClass("first-no-border"); 
  
  $(".commit-tree li ul").hide();
  $(".commit-tree li.tree > a").click(function (){
    $(this).next("ul").toggle();
    return false;
  });
});
