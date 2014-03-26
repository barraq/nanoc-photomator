# encoding: utf-8

Nanoc::CLI.after_setup do
  filename = File.dirname(__FILE__) + "/commands/photomator.rb"
  photomator_cmd = Nanoc::CLI.load_command_at(filename)

  task_filenames = Dir[File.dirname(__FILE__) + '/tasks/*.rb']
  task_filenames.each do |filename|
    task = Nanoc::CLI.load_command_at(filename)
    photomator_cmd.add_command(task)
  end

  Nanoc::CLI.add_command(photomator_cmd)
end