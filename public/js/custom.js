$(function() {
  $('.js-nav').click(function() {
    location.href = $(this).data('href');
  });

  $('#pjax-container').pjax('#js-tree a, #js-tree-nav a').on('pjax:send', function(){
    $('#loader').show();
  });

  // filter repositories
  $('.js-filter-query').on('keyup', function(e) {
    var regexp = new RegExp($(this).val(), 'i'),
        $repolist = $('.js-repolist li');

    $repolist.hide();
    $repolist.filter(function() {
      return regexp.test($(this).text());
    }).show();
  });
});
