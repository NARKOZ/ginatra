$(document).ready(function (){
  $(".commit-tree li ul").hide();
  $(".commit-tree li.tree > a").click(function (){
    $(this).next("ul").toggle();
    return false;
  });
});
