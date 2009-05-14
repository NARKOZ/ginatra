$(document).ready(function (){
  $(".commit-info tr:first-child td").addClass("first-no-border"); 
  $(".commit-author tr:first-child td").addClass("first-no-border"); 
  $(".commit-committer tr:first-child td").addClass("first-no-border"); 
  $(".commit-files tr:first-child td").addClass("first-no-border"); 
  $(".commit-log tr:first-child td").addClass("first-no-border"); 
  $(".repo-list dl dt:first-child").addClass("first-no-border"); 
  $(".CodeRay .c:before").addClass("before-c");
  $(".CodeRay .ins .ins:after").addClass("before-line");
  $(".CodeRay .ins .ins:before").addClass("before-line");
  $(".CodeRay .del .del:after").addClass("before-line");
  $(".CodeRay .del .del:before").addClass("before-line");
  $(".CodeRay .chg .chg:before").addClass("before-line");
  
  $(".commit-tree li ul").hide();
  $(".commit-tree li a").click(function (){
    $(this).next("ul").toggle();
    return false;
  });
});
