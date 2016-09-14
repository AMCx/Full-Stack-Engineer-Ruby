require 'timeout'

module WaitForAjax
  def click_ajax_link(locator, options = {})
    click_link(locator, options)

    wait_for_ajax
  end

  def click_ajax_button(locator, options = {})
    click_button(locator, options)

    wait_for_ajax
  end

  def click_ajax_link_or_button(locator, options = {})
    click_link_or_button(locator, options)

    wait_for_ajax
  end

  def wait_for_ajax(&block)
    block.call if block

    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        sleep 0.1
        break if finished_all_ajax_requests?
      end
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end