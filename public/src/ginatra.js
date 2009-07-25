$(document).ready(function (){
  // To be fixed, later when I finish moving furniture.
  
  $(".commit-tree li ul").hide();
  $(".commit-tree li.tree > a").click(function (){
    $(this).next("ul").toggle();
    return false;
  });
});
