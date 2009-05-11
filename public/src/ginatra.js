$(document).ready(function (){
  $(".commit-info tr:first-child td").addClass("first-no-border"); 
  $(".commit-author tr:first-child td").addClass("first-no-border"); 
  $(".commit-committer tr:first-child td").addClass("first-no-border"); 
  $(".commit-files tr:first-child td").addClass("first-no-border"); 
  $(".commit-log tr:first-child td").addClass("first-no-border"); 
  $(".commit-tree li ul").hide();
  $(".commit-tree li a").click(function (){
    $(this).next("ul").toggle();
    return false;
  });
});
