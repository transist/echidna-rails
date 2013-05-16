class Job
  constructor: ->
    self = this
    $('#live').on 'change', (event)->
      self.liveCheck()
    jobId = $('#trends_job_id').data('job-id')
    @checkJobStatus(jobId)

  checkJobStatus: (jobId)->
    self = this
    $('.spinner').show()
    $.poll (retry) ->
      $.getJSON "/jobs/" + jobId + "/status.json", (data)->
        if data["status"] == "complete"
          if data["payload"].length == 0
            $('#trends').html $('<p>Not available</p>')
          else
            $('#trends').html $('<table><thead><tr><th>Keyword</th><th>Z-score</th></tr></thead><tbody><tbody></table>')
            $.each data["payload"], (index, row)->
              $('#trends tbody').append("<tr><td>"+row['word']+"</td><td>"+row['z_score']+"</td></tr>")
          $('.spinner').hide()
          if $('#live').prop("checked")
            self.liveCheck()
        else
          retry()

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
