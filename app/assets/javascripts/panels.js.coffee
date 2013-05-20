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
    $.poll (retry) ->
      $.getJSON "/jobs/" + jobId + "/status.json", (data)->
        if data["status"] == "complete"
          if data["payload"].length == 0
            $('#trends').html $('<p>Not available</p>')
          else
            $('#trends').html $('<table><thead><tr><th>Keyword</th><th>Z-score</th><th></th></tr></thead><tbody><tbody></table>')
            $.each data["payload"], (index, row)->
              $('#trends tbody').append("<tr><td>"+row['word']+"</td><td>"+row['z_score']+"</td><td><a href='#' class='stopword'>Ignore</a></td></tr>")
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
