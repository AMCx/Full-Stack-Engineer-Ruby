var app = window.app = {};
app.comics = function () {

    var that = this;

    this.loadScreen = function () {

        that.draw();

        that.getElementReferences();

        that.addEventListeners();

        that.applyPlugins();

    };

    this.draw = function () {
    };

    this.getElementReferences = function () {

        // Cache some selectors
        that.screenContainer = $('.comics');
        that.form = $('form#comics-search-form');
        that.mainSearchField = that.form.find("[role='main-search']");

        that.favorite = that.screenContainer.find("[role='favorite']");

        return that;
    };

    this.applyPlugins = function () {
        var cache = {};
        $(that.mainSearchField).autocomplete({
            selectFirst: true,
            source: function (request, response) {

                var term = request.term;
                if (term in cache) {
                    response(cache[term]);
                    return;
                }

                $.getJSON("/api/characters?term=" + request.term, function (data) {

                    cache[term] = data;

                    response($.map(data.characters, function (character) {
                        return {
                            label: character.name,
                            value: character.id,
                            url: character.comics_url
                        };
                    }));
                });
            },
            minLength: 2,
            delay: 100,
            select: function (event, ui) {

                $("#character-name").val(ui.item.label);
                $("#character-id").val(ui.item.value);
                $("#character-description").html(ui.item.url);
                return false;
            }
        }).autocomplete("instance")._renderItem = function (ul, item) {
            console.log('ui.item: ', item);
            return $("<li>")
                .append("<div>" +
                    "<img id=\"character-icon\" src=\"" + item.icon + "\" class=\"ui-state-default\" alt=\"\">" +
                    item.label + "<br>" + item.url + item.icon + "</div>")
                .appendTo(ul);
        };
        ;

        /*
         var cache = {};
         $(that.mainSearchField).autocomplete({
         minLength: 0,
         selectFirst: true,
         change: that.onMainSearchChange,
         focus: function () {
         // prevent value inserted on focus
         return false;
         },
         source: function (request, response) {
         var term = request.term;
         if (term in cache) {
         response(cache[term]);
         return;
         }

         $.getJSON('/api/characters', request, function (data, status, xhr) {
         cache[term] = data;
         response(data);
         });
         }
         });
         */

    };

    //Methods

    this.onMainSearchChange = function (evt) {
        console.log('onMainSearchChange');
    };

    this.remoteCallFailure = function (jqXHR, textStatus, errorThrown) {
        utils.hideLoading();

        var _data = $.parseJSON(jqXHR.responseText);
        $.notify({
            message: _data.message
        }, {
            type: 'danger',
            newest_on_top: true,
            delay: 3000
        });
    }

    this.onAddFavorite = function (favorite) {

        var _data = {
            favorite: {comic_id: favorite.data('comic-id')}
        }

        var _success = function (data) {
            favorite.addClass('heart-on');
            favorite.removeClass('heart-off');

            utils.hideLoading();
            $.notify({
                message: data.message
            }, {
                type: 'success',
                newest_on_top: true,
                delay: 2000
            });

        };

        utils.showLoading();
        $.ajax({
            type: "POST",
            url: "/api/favorites/",
            dataType: "json",
            data: _data,
            success: _success,
            error: that.remoteCallFailure
        })

    }

    this.onRemoveFavorite = function (favorite) {

        var data = {
            id: favorite.data('comic-id'),
            "_method": "delete"
        }

        var _success = function (data) {
            favorite.addClass('heart-off');
            favorite.removeClass('heart-on');
            utils.hideLoading();

            $.notify({
                message: data.message
            }, {
                type: 'success',
                newest_on_top: true,
                delay: 2000
            });

        };
        utils.showLoading();
        $.ajax({
            type: "DELETE",
            url: "/api/favorites/" + favorite.data('comic-id'),
            dataType: "json",
            data: data,
            success: _success,
            error: that.remoteCallFailure
        })
    }


    this.onToggleFavorite = function () {
        var _favorite = $(this);

        if (_favorite.hasClass('heart-off')) {

            that.onAddFavorite(_favorite);

        } else {
            that.onRemoveFavorite(_favorite);
        }
     };

    this.addEventListeners = function () {

        $(that.favorite).on('click', that.onToggleFavorite);

        //$(that.mainSearchField).on('click', that.onExperiencesTabElemSelected);

        $(that.form).submit(function () {
            utils.showLoading();
            return true;
        });

    };

    this.loadScreen();


}
;

$(document).ready(app.comics);
$(document).on('page:load', app.comics);
