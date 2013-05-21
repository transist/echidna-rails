class Job
  constructor: ->
    self = this
    $('#live').on 'change', (event)->
      self.liveCheck()

    @trends_template = "<table class='stats'>
                         <caption>Positive Trends</caption>
                         <thead>
                           <tr>
                             <th>Keyword</th>
                             <th>Score</th>
                             <th>Current</th>
                             <th></th>
                           </tr>
                         </thead>
                         <tbody>
                         {{#payload.positive_stats}}
                           <tr>
                             <td><a href='#' class='word'>{{word}}</a></td>
                             <td>{{z_score}}</td>
                             <td>{{current_stat}}</td>
                             <td><a href='#' class='stopword'>Ignore</a></td>
                           </tr>
                         {{/payload.positive_stats}}
                         </tbody>
                        </table>
                        <table class='stats'>
                         <caption>Negative Trends</caption>
                         <thead>
                           <tr>
                             <th>Keyword</th>
                             <th>Score</th>
                             <th>Current</th>
                             <th></th>
                           </tr>
                         </thead>
                         <tbody>
                         {{#payload.negative_stats}}
                           <tr>
                             <td><a href='#' class='word'>{{word}}</a></td>
                             <td>{{z_score}}</td>
                             <td>{{current_stat}}</td>
                             <td><a href='#' class='stopword'>Ignore</a></td>
                           </tr>
                         {{/payload.negative_stats}}
                         </tbody>
                        </table>
                        <table class='stats'>
                         <caption>Zero Trends</caption>
                         <thead>
                           <tr>
                             <th>Keyword</th>
                             <th>Score</th>
                             <th>Current</th>
                             <th></th>
                           </tr>
                         </thead>
                         <tbody>
                         {{#payload.zero_stats}}
                           <tr>
                             <td><a href='#' class='word'>{{word}}</a></td>
                             <td>{{z_score}}</td>
                             <td>{{current_stat}}</td>
                             <td><a href='#' class='stopword'>Ignore</a></td>
                           </tr>
                         {{/payload.zero_stats}}
                         </tbody>
                        </table>"
    @tweets_template = "<table>
                          <caption>Tweets</caption>
                          <thead>
                            <tr>
                              <th>Content</th>
                              <th>Posted At</th>
                            </tr>
                          </thead>
                          <tbody>
                          {{#payload}}
                            <tr>
                              <td>{{content}}</td>
                              <td><a href='http://t.qq.com/p/t/{{target_id}}' target='_blank'>{{posted_at}}</a></td>
                            </tr>
                          {{/payload}}
                          </tbody>
                        </table>"
    jobId = $('#trends_job_id').data('job-id')
    @checkJobStatus(jobId)

    @addStopword()
    @readTweets()

  checkJobStatus: (jobId)->
    self = this
    $('.spinner').show()
    $.poll 5000, (retry) ->
      $.getJSON "/jobs/" + jobId + "/status.json", (data)->
        if data["status"] == "complete"
          if data["payload"].length == 0
            $('#trends').html $('<p>Not available</p>')
          else
            $('#trends').html $.mustache(self.trends_template, data)
          $('.spinner').hide()
          if $('#live').prop("checked")
            self.liveCheck()
        else
          retry()

  checkTweetsJobStatus: (jobId) ->
    self = this
    $('.spinner').show()
    $.poll 5000, (retry) ->
      $.getJSON "/jobs/" + jobId + "/status.json", (data)->
        if data["status"] == "complete"
          if data["payload"].length == 0
            $('#tweets').html $('<p>Not available</p>')
          else
            $('#tweets').html $.mustache(self.tweets_template, data)
          $('.spinner').hide()
          if $('#live').prop("checked")
            self.liveCheck()
        else
          retry()


  addStopword: ->
    $(document).on 'click', '.stopword', ->
      word_row = $(this).parents('tr')
      word = word_row.children().first().text()
      $.ajax '/add_stopword',
        data: JSON.stringify({word: word}),
        contentType: 'application/json',
        type: 'POST',
        success: ->
          word_row.remove()
      false

  readTweets: ->
    self = this
    $(document).on 'click', '.word', ->
      console.log $(this)
      console.log $(this).text()
      tweets_url = '/panels/' + self.getPanelId() + '/tweets.json?period=' + self.getPeriod() + '&word=' + $(this).text()
      console.log tweets_url
      $.getJSON tweets_url, (data)->
        setTimeout ->
          self.checkTweetsJobStatus data["job_id"]
        , 5000
      false

  liveCheck: ->
    self = this
    if $('#live').prop("checked")
      check_url = '/panels/' + @getPanelId() + '/trends.json?period=' + @getPeriod()
      $.getJSON check_url, (data)->
        setTimeout ->
          self.checkJobStatus(data["job_id"])
        , 5000

  getPanelId: ->
    window.location.pathname.split('/')[2]

  getPeriod: ->
    url = window.location.href
    period_check = /[?&]period=([^&]+)/i
    match = period_check.exec(url)
    if match != null
      match[1]
    else
      "day"

$ ->
  new Job()
