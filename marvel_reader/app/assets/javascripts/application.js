// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui/autocomplete
//= require bootstrap
//= require external_lib/bootstrap-notify

// require turbolinks
//= require_tree .

var utils = window.utils = {};



utils.showLoading = function () {
    $("#preloader").addClass("loading").show();
    return this
};
utils.hideLoading = function () {
    $("#preloader").removeClass("loading").fadeOut();
    return this
};

utils.updateQueryStringParameter = function(uri, key, value) {
    var re = new RegExp("([?|&])" + key + "=.*?(&|#|$)", "i");
    if (uri.match(re)) {
        return uri.replace(re, '$1' + key + "=" + value + '$2');
    } else {
        var hash =  '';
        if( uri.indexOf('#') !== -1 ){
            hash = uri.replace(/.*#/, '#');
            uri = uri.replace(/#.*/, '');
        }
        var separator = uri.indexOf('?') !== -1 ? "&" : "?";
        return uri + separator + key + "=" + value + hash;
    }
};

$(window).scroll(function() {
    if ($(".navbar").offset().top > 50) {
        $('#custom-nav').addClass('affix');
        $(".navbar-fixed-top").addClass("top-nav-collapse");
    } else {
        $('#custom-nav').removeClass('affix');
        $(".navbar-fixed-top").removeClass("top-nav-collapse");
    }
});