$(function() {
  hljs.initHighlightingOnLoad();

  $('.js-nav').click(function(){
    location.href = $(this).data('href');
  });

  $('#pjax-container').pjax('#js-tree a, #js-tree-nav a').on('pjax:send', function(){
    $('#loader').show();
  });
});
