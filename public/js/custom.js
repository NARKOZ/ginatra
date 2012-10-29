$(function() {
  hljs.initHighlightingOnLoad();

  $('.js-nav').click(function(){
    location.href = $(this).data('href');
  });

  $('#pjax-container').pjax('#tree a').on('pjax:send', function(){
    $('#loader').show();
  });
});
