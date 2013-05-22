class Job
  constructor: ->
    self = this

    @trends_template = "<table class='stats table table-striped'>
                         <caption>Positive Trends</caption>
                         <thead>
                           <tr>
                             <th>Keyword</th>
                             <th>Score</th>
                             <th class='freq'>Freq</th>
                             <th></th>
                           </tr>
                         </thead>
                         <tbody>
                         {{#positive_stats}}
                           <tr>
                             <td><a href='#' class='word'>{{word}}</a></td>
                             <td>{{z_score}}</td>
                             <td>{{current_stat}}</td>
                             <td><a href='#' class='stopword'><span class='icon-remove'></span></a></td>
                           </tr>
                         {{/positive_stats}}
                         </tbody>
                        </table>
                        <table class='stats table table-striped'>
                         <caption>Negative Trends</caption>
                         <thead>
                           <tr>
                             <th>Keyword</th>
                             <th>Score</th>
                             <th class='freq'>Freq</th>
                             <th></th>
                           </tr>
                         </thead>
                         <tbody>
                         {{#negative_stats}}
                           <tr>
                             <td><a href='#' class='word'>{{word}}</a></td>
                             <td>{{z_score}}</td>
                             <td>{{current_stat}}</td>
                             <td><a href='#' class='stopword'><span class='icon-remove'></span></a></td>
                           </tr>
                         {{/negative_stats}}
                         </tbody>
                        </table>
                        <table class='stats table table-striped'>
                         <caption>Zero Trends</caption>
                         <thead>
                           <tr>
                             <th>Keyword</th>
                             <th>Score</th>
                             <th class='freq'>Freq</th>
                             <th></th>
                           </tr>
                         </thead>
                         <tbody>
                         {{#zero_stats}}
                           <tr>
                             <td><a href='#' class='word'>{{word}}</a></td>
                             <td>{{z_score}}</td>
                             <td>{{current_stat}}</td>
                             <td><a href='#' class='stopword'><span class='icon-remove'></span></a></td>
                           </tr>
                         {{/zero_stats}}
                         </tbody>
                        </table>"
    @tweets_template = "<table class='tweets table table-striped'>
                          <caption>Tweets</caption>
                          <thead>
                            <tr>
                              <th>{{word}}</th>
                            </tr>
                          </thead>
                          <tbody>
                          {{#tweets}}
                            <tr>
                              <td>
                                <p>{{content}}</p>
                                <p><a href='http://t.qq.com/p/t/{{target_id}}' target='_blank'>{{posted_at}}</a></p>
                              </td>
                            </tr>
                          {{/tweets}}
                          </tbody>
                        </table>"

    @period = "week"
    @initPanelWidgets()

  initPanelWidgets: ->
    self = this
    $.each $('.panel'), (index, panelWidget) ->
      self.initPanelLinks()
      self.initLiveCheck(panelWidget)
      self.initPeriodLinks(panelWidget)
      self.initWordLinks(panelWidget)
      self.initIgnoreLinks(panelWidget)

    panelWidget = $('.panel:first')
    self.sendTrendsRequest(panelWidget)

  initPanelLinks: ->
    self = this
    $('.panels-tabs a').click (event) ->
      panelSelector = $(event.target).attr('href')
      panelWidget = $(panelSelector).find('.panel')
      unless panelWidget.data('send')
        self.sendTrendsRequest(panelWidget)


  initLiveCheck: (panelWidget)->
    self = this
    $(panelWidget).find('.live').on 'change', ->
      self.liveCheck(panelWidget)
      false

  initPeriodLinks: (panelWidget)->
    self = this
    $(panelWidget).find('.periods').on 'click', 'a', (event)->
      $(panelWidget).find('.spinner').show()
      $(panelWidget).find('.trends').html ''
      $(panelWidget).find('.periods li').removeClass('active')
      $(event.target).parent().addClass('active')
      self.period = $(event.target).data('period')
      self.sendTrendsRequest(panelWidget)
      false

  initWordLinks: (panelWidget)->
    self = this
    $(panelWidget).on 'click', '.word', (event)->
      $(panelWidget).find('.spinner').show()
      panelId = $(panelWidget).data('panel-id')
      word = $(event.target).text()
      tweets_url = '/panels/' + panelId + '/tweets.json?period=' + self.period + '&word=' + word
      $.getJSON tweets_url, (data)->
        setTimeout ->
          self.checkTweetsJobStatus panelWidget, data["job_id"]
        , 5000
      false

  initIgnoreLinks: (panelWidget)->
    $(panelWidget).on 'click', '.stopword', ->
      $(panelWidget).find('.spinner').show()
      word_row = $(this).parents('tr')
      word = word_row.find('.word').text()
      $.ajax '/add_stopword',
        data: JSON.stringify({word: word}),
        contentType: 'application/json',
        type: 'POST',
        success: ->
          word_row.remove()
      false

  checkJobStatus: (panelWidget, jobId)->
    self = this
    $.poll 5000, (retry) ->
      $.getJSON "/jobs/" + jobId + "/status.json", (data)->
        if data["status"] == "complete"
          if data["payload"].length == 0
            $(panelWidget).find('.trends').html $('<p>Not available</p>')
          else
            $(panelWidget).find('.trends').html $.mustache(self.trends_template, data["payload"])
          $(panelWidget).find('.spinner').hide()
          if $(panelWidget).find('.live').prop("checked")
            self.liveCheck(panelWidget)
        else
          retry()

  checkTweetsJobStatus: (panelWidget, jobId) ->
    self = this
    $.poll 5000, (retry) ->
      $.getJSON "/jobs/" + jobId + "/status.json", (data)->
        if data["status"] == "complete"
          if data["payload"].length == 0
            $(panelWidget).find('.tweets').html $('<p>Not available</p>')
          else
            $(panelWidget).find('.tweets').html $.mustache(self.tweets_template, data["payload"])
          $(panelWidget).find('.spinner').hide()
        else
          retry()

  sendTrendsRequest: (panelWidget)->
    self = this
    panelId = $(panelWidget).data('panel-id')
    trendsUrl = "/panels/" + panelId + "/trends.json?period=" + self.period
    panelWidget.data('send', true)
    $.getJSON trendsUrl, (data)->
      setTimeout ->
        self.checkJobStatus(panelWidget, data["job_id"])
      , 5000

  readTweets: ->
    self = this
    $(document).on 'click', '.word', ->
      $('.spinner').show()
      tweets_url = '/panels/' + self.getPanelId() + '/tweets.json?period=' + self.getPeriod() + '&word=' + $(this).text()
      $.getJSON tweets_url, (data)->
        setTimeout ->
          self.checkTweetsJobStatus data["job_id"]
        , 5000
      false

  liveCheck: (panelWidget)->
    self = this
    if $(panelWidget).find('.live').prop("checked")
      $(panelWidget).find('.spinner').show()
      panelId = $(panelWidget).data('panel-id')
      check_url = '/panels/' + panelId + '/trends.json?period=' + self.period
      $.getJSON check_url, (data)->
        setTimeout ->
          self.checkJobStatus(panelWidget, data["job_id"])
        , 10000

$ ->
  new Job()
