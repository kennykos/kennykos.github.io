function renderRandomQuote(quotes, $quoteBox) {
    if (!Array.isArray(quotes) || quotes.length === 0) {
        return;
    }

    var chosen = quotes[Math.floor(Math.random() * quotes.length)];
    if (!chosen || !chosen.content) {
        return;
    }

    var $attr = $quoteBox.find('#random-quote-attr');
    $attr.empty();
    if (chosen.author) {
        $attr.append(document.createTextNode(chosen.author));
    }
    if (chosen.source) {
        if (chosen.author) {
            $attr.append(document.createTextNode(', '));
        }
        $attr.append($('<em></em>').text(chosen.source));
    }

    var $text = $quoteBox.find('#random-quote-text');
    $text.empty();
    String(chosen.content).split('\n').forEach(function(line, idx) {
        if (idx > 0) {
            $text.append('<br>');
        }
        $text.append(document.createTextNode(line));
    });

    $quoteBox.show();
}

$(document).ready(function() {
    $('a.abstract').click(function() {
        $(this).parent().parent().find(".abstract.hidden").toggleClass('open');
        $(this).parent().parent().find(".bibtex.hidden.open").toggleClass('open');
    });
    $('a.bibtex').click(function() {
        $(this).parent().parent().find(".bibtex.hidden").toggleClass('open');
        $(this).parent().parent().find(".abstract.hidden.open").toggleClass('open');
    });
    $('a').removeClass('waves-effect waves-light');

    // Random quote box (e.g. on the about page)
    var $quoteBox = $('#random-quote-box');
    var $quoteData = $('#random-quote-data');
    if ($quoteBox.length && $quoteData.length) {
        try {
            var quotes = JSON.parse($quoteData.text());
            renderRandomQuote(quotes, $quoteBox);
        } catch (e) {
            console.error('Could not parse quotes data:', e);
        }
    }
});
