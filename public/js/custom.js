$(function() {
  hljs.initHighlightingOnLoad();

  $('.js-nav').click(function(){
    location.href = $(this).data('href');
  });

  $('#tree li ul').hide();
  $('#tree li.tree > a').click(function (){
    $(this).next('ul').toggle();
    $(this).find('i').toggleClass('icon-folder-open');
    return false;
  });
});
