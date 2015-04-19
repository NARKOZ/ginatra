$(function() {
  $(window).scroll(function() {
    if ($(window).scrollTop() >= 220) {
      $('.hidden-header').show();
    } else {
      $('.hidden-header').hide();
    }
  });

  $('[data-toggle="tooltip"]').tooltip();

  $('.js-lazy').lazyload({
    effect: 'fadeIn',
    threshold: 200
  });

  $('#js-toggle-file-listing').click(function() {
    var text = $(this).text();
    $(this).text(text == 'Show file listing' ? 'Hide file listing': 'Show file listing');
    $('#js-file-listing').toggle();
  });

  function selectText() {
    var range;

    if (document.selection) {
      range = document.body.createTextRange();
      range.moveToElementText(this);
      range.select();
    } else if (window.getSelection) {
      range = document.createRange();
      range.selectNode(this);
      window.getSelection().addRange(range);
    }
  }

  $('#js-clone-url').click(selectText);

  $('.js-nav').click(function() {
    location.href = $(this).data('href');
  });

  $('#pjax-container').pjax('#js-tree a, #js-tree-nav a').on('pjax:send', function() {
    $('#loader').show();
  }).on('pjax:end', function() {
    $('#js-clone-url').click(selectText);
  });

  // filter repositories
  $('.js-filter-query').on('keyup', function() {
    var regexp = new RegExp($(this).val(), 'i'),
        $repolist = $('.js-repolist a');

    $repolist.hide();
    $repolist.filter(function() {
      return regexp.test($(this).text());
    }).show();
  });
});
