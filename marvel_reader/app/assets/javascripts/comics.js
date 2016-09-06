var app = window.app = {};

app.comics = function () {

    var that = this;

    this.loadScreen = function () {

        console.log('loadScreen ...');
        that.draw();

        that.getElementReferences();

        that.addEventListeners();

        that.applyPlugins();

    };

    this.draw = function () {     };

    this.getElementReferences = function () {

        // Cache some selectors
        that.screenContainer = $('.comics');
        that.form = $('form#comics-search-form');
        that.mainSearchField = that.form.find("[role='main-search']");

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
            select: function( event, ui ) {

                $( "#character-name" ).val( ui.item.label );
                $( "#character-id" ).val( ui.item.value );
                $( "#character-description" ).html( ui.item.url );
                return false;
            }
        }).autocomplete( "instance" )._renderItem = function( ul, item ) {
            console.log('ui.item: ', item);
            return $( "<li>" )
                .append( "<div>" +
                    "<img id=\"character-icon\" src=\""+item.icon+"\" class=\"ui-state-default\" alt=\"\">" +
                    item.label + "<br>" + item.url + "</div>" )
                .appendTo( ul );
        };;

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



    this.addEventListeners = function () {
        //$(that.mainSearchField).on('click', that.onExperiencesTabElemSelected);

        $(that.form).submit(function () {
            showLoading();
            return true;
        });

    };

    this.loadScreen();


};

$(document).ready(app.comics);
$(document).on('page:load', app.comics);
