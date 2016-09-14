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
        that.comicMosaic = that.screenContainer.find('.mosaic');
        that.form = $('form#comics-search-form');
        that.searchCharacterName = that.form.find("#character-name");
        that.searchCharacterId = that.form.find("#character-id");
        that.mainSearchField = that.form.find("[role='main-search']");

        that.favorite = that.screenContainer.find("[role='favorite']");
        that.nextPage = that.screenContainer.find("[role='next-page']");
        that.previousPage = that.screenContainer.find("[role='previous-page']");
        that.rootLnk = that.screenContainer.find("[role='root-link']");
        that.logo = that.screenContainer.find("#logo");

        return that;
    };

    this.applyPlugins = function () {

        $(that.mainSearchField).autocomplete({
            selectFirst: true,
            source: function (request, response) {

                $(that.searchCharacterName).addClass('loading');

                var term = request.term;

                $.getJSON("/api/characters?term=" + request.term, function (data) {

                    $(that.searchCharacterName).removeClass('loading');

                    response($.map(data.characters, function (character) {
                        return {
                            name: character.name,
                            id: character.id,
                            icon: character.icon
                        };
                    }));
                });
            },
            minLength: 2,
            delay: 100,
            appendTo: '#character-search-results',
            select: function (event, ui) {

                $("#character-name").val(ui.item.name);
                $("#character-id").val(ui.item.id);

                that.form.submit();

                return false;
            }
        }).autocomplete("instance")._renderItem = function (ul, item) {

            return $("<li class='ui-character' id='ui-character-"+item.id+"'>")
                .data( "ui-autocomplete-item", item )
                .append("<span>" + "<img id=\"character-icon\" src=\"" + item.icon + "\" class=\"ui-state-default\" alt=\"\">" + "</span>")
                .append("<span>" +item.name + "</span>")
                .appendTo(ul);

        };

    };

    //Methods

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
    };

    this.onAddFavorite = function (favorite) {

        var _data = {
            favorite: {comic_id: favorite.data('comic-id')}
        }

        var _success = function (data) {
            favorite.parent().addClass('favorite-comic');
            favorite.addClass('heart-on');
            favorite.removeClass('heart-off');

            //utils.hideLoading();
            $.notify({
                message: data.message
            }, {
                type: 'success',
                newest_on_top: true,
                delay: 2000
            });

        };

        //utils.showLoading();
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
            favorite.parent().removeClass('favorite-comic');
            favorite.addClass('heart-off');
            favorite.removeClass('heart-on');
            //utils.hideLoading();

            $.notify({
                message: data.message
            }, {
                type: 'success',
                newest_on_top: true,
                delay: 2000
            });

        };
        //utils.showLoading();
        $.ajax({
            type: "DELETE",
            url: "/api/favorites/" + favorite.data('comic-id'),
            dataType: "json",
            data: data,
            success: _success,
            error: that.remoteCallFailure
        })
    };

    this.onToggleFavorite = function () {
        var _favorite = $(this);

        if (_favorite.hasClass('heart-off')) {

            that.onAddFavorite(_favorite);

        } else {
            that.onRemoveFavorite(_favorite);
        }
    };

    this.onGoToNextPage = function( event ) {
        utils.showLoading();
    };

    this.onGoToPreviousPage = function( event ) {
        utils.showLoading();
    };

    this.onShowDetails = function( event ) {
        var _comic = $(this);
        var _favorite = _comic.find('.favorites');
        var _info = _comic.find('.comic-info-container');
        var _release = _comic.find('.comic-release-container');
        _comic.find('.comic-item').addClass('layer');
        _favorite.removeClass('hidden');
        _info.removeClass('hidden');
        _release.removeClass('hidden');
    };

    this.onHideDetails = function( event ) {
        var _comic = $(this);
        var _favorite = _comic.find('.favorites');
        var _info = _comic.find('.comic-info-container');
        var _release = _comic.find('.comic-release-container');

        _comic.find('.comic-item').removeClass('layer');
        if(_favorite.hasClass('heart-off')){
            _favorite.addClass('hidden');
        }
        _info.addClass('hidden');
        _release.addClass('hidden');

    };

    this.addEventListeners = function () {

        $(that.comicMosaic).on('mouseover', that.onShowDetails);
        $(that.comicMosaic).on('mouseout', that.onHideDetails);
        $(that.favorite).on('click', that.onToggleFavorite);
        $(that.nextPage).on('click', that.onGoToNextPage);
        $(that.previousPage).on('click', that.onGoToPreviousPage);
        $(that.rootLnk).on('click', utils.showLoading);

        $(that.form).submit(function (e) {
            utils.showLoading();

            if($(that.searchCharacterName).val() == ''){
                $(that.searchCharacterId).val('');
            }

            var _characterId= $(that.searchCharacterId).val();
            
            return true;
        });

    };

    this.loadScreen();

};

$(document).ready(app.comics);
$(document).on('page:load', app.comics);
