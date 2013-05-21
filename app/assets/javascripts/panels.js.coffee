class Job
  constructor: ->
    self = this
    $('#live').on 'change', (event)->
      self.liveCheck()

    jobId = $('#trends_job_id').data('job-id')
    @checkJobStatus(jobId)

    @addStopword()

  checkJobStatus: (jobId)->
    self = this
    $('.spinner').show()
    $.poll 5000, (retry) ->
      $.getJSON "/jobs/" + jobId + "/status.json", (data)->
        if data["status"] == "complete"
          if data["payload"].length == 0
            $('#trends').html $('<p>Not available</p>')
          else
            $('#trends').html ''
            positive_stats = data["payload"]["positive_stats"]
            $('#trends').append $('<table class="stats"><caption>Positive Trends</caption><thead><tr><th>Keyword</th><th>Z-score</th><th>Current Frequency</th><th></th></tr></thead><tbody><tbody></table>')
            $.each positive_stats, (index, row)->
              $('#trends tbody').append("<tr><td>"+row['word']+"</td><td>"+row['z_score']+"</td><td>"+row['current_stat']+"</td><td><a href='#' class='stopword'>Ignore</a></td></tr>")
            zero_stats = data["payload"]["zero_stats"]
            $('#trends').append $('<table class="stats"><caption>Zero Trends</caption><thead><tr><th>Keyword</th><th>Z-score</th><th>Current Frequency</th><th></th></tr></thead><tbody><tbody></table>')
            $.each zero_stats, (index, row)->
              $('#trends tbody').append("<tr><td>"+row['word']+"</td><td>"+row['z_score']+"</td><td>"+row['current_stat']+"</td><td><a href='#' class='stopword'>Ignore</a></td></tr>")
            negative_stats = data["payload"]["negative_stats"]
            $('#trends').append $('<table class="stats"><caption>Negative Trends</caption><thead><tr><th>Keyword</th><th>Z-score</th><th>Current Frequency</th><th></th></tr></thead><tbody><tbody></table>')
            $.each negative_stats, (index, row)->
              $('#trends tbody').append("<tr><td>"+row['word']+"</td><td>"+row['z_score']+"</td><td>"+row['current_stat']+"</td><td><a href='#' class='stopword'>Ignore</a></td></tr>")
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
        data : JSON.stringify({word: word}),
        contentType : 'application/json',
        type : 'POST',
        success: ->
          word_row.remove()
      false

  liveCheck: ->
    self = this
    if $('#live').prop("checked")
      url = window.location.href
      elements = url.split('/')
      last_element = elements[elements.length - 1]
      check_url = '/panels/' + elements[elements.length - 2] + '/trends.json?' + last_element.substring(7, last_element.length)
      $.getJSON check_url, (data)->
        setTimeout ->
          self.checkJobStatus(data["job_id"])
        , 5000

$ ->
  new Job()
