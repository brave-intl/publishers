#!/usr/bin/env ruby

# A sneaky wrapper around Rubocop that allows you to run it only against
# the recent changes, as opposed to the whole project. It lets you
# enforce the style guide for new/modified code only, as opposed to
# having to restyle everything or adding cops incrementally. It relies
# on git to figure out which files to check.
#
# Here are some options you can pass in addition to the ones in rubocop:
#
#   --local               Check only the changes you are about to push
#                         to the remote repository.
#
#   --uncommitted         Check only changes in files that have not been
#   --index               committed (i.e. either in working directory or
#                         staged).
#
#   --against REFSPEC     Check changes since REFSPEC. This can be
#                         anything that git will recognize.
#
#   --branch              Check only changes in the current branch.
#
#   --courage             Without this option, only the modified lines
#                         are inspected. When supplied, it will check
#                         the full contents of the file. You should have
#                         the courage to fix your style violations as
#                         you see them, you know.
#
# Caveat emptor:
#
# * Monkey patching ahead. This script relies on Rubocop internals and
#   has been tested against 0.25.0. Newer (or older) versions might
#   break it.
#
# * While it does try to check modified lines only, there might be some
#   quirks. It might not show offenses in modified code if they are
#   reported at unmodified lines. It might also show offenses in
#   unmodified code if they are reported in modified lines.

require "rubocop"

module DirtyCop
  extend self # In your face, style guide!

  def bury_evidence?(file, line)
    !report_offense_at?(file, line)
  end

  def uncovered_targets
    @files
  end

  def cover_up_unmodified(ref, only_changed_lines = true)
    @files = files_modified_since(ref)
    @line_filter = build_line_filter(@files, ref) if only_changed_lines
  end

  def process_bribe
    eat_a_donut if ARGV.empty?

    ref = nil
    only_changed_lines = true

    loop do
      arg = ARGV.shift
      case arg
      when "--local"
        ref = `git rev-parse --abbrev-ref --symbolic-full-name @{u}`.chomp
        exit 1 unless $CHILD_STATUS.success?
      when "--against"
        ref = ARGV.shift
      when "--uncommitted", "--index"
        ref = "HEAD"
      when "--branch"
        ref = `git merge-base HEAD master`.chomp
      when "--courage"
        only_changed_lines = false
      else
        ARGV.unshift arg
        break
      end
    end

    return unless ref

    cover_up_unmodified ref, only_changed_lines
  end

  private

  def report_offense_at?(file, line)
    !@line_filter || @line_filter.fetch(file)[line]
  end

  def files_modified_since(ref)
    `git diff --diff-filter=AM --name-only #{ref}`
      .lines
      .map(&:chomp)
      .grep(/\.rb$/)
      .map { |file| File.absolute_path(file) }
  end

  def build_line_filter(_files, ref)
    result = {}

    suspects = files_modified_since(ref)
    suspects.each do |file|
      result[file] = lines_modified_since(file, ref)
    end

    result
  end

  def lines_modified_since(file, ref)
    ranges =
      `git diff -p -U0 #{ref} #{file}`
      .lines
      .grep(/^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@/) { Regexp.last_match(1).to_i...(Regexp.last_match(1).to_i + Regexp.last_match(2).to_i) }
      .reverse

    mask = Array.new(ranges.first.end)

    ranges.each do |range|
      range.each do |line|
        mask[line] = true
      end
    end

    mask
  end

  def eat_a_donut
    puts "#{$PROGRAM_NAME}: The dirty cop Alex Murphy could have been"
    puts
    puts File.read(__FILE__)[/(?:^#(?:[^!].*)?\n)+/s].gsub(/^#/, "   ")
    exit
  end
end

module RuboCop
  class TargetFinder
    alias find_unpatched find

    def find(args)
      replacement = DirtyCop.uncovered_targets
      return replacement if replacement

      find_unpatched(args)
    end
  end

  class Runner
    alias inspect_file_unpatched inspect_file

    def inspect_file(file)
      offenses, updated = inspect_file_unpatched(file)
      offenses = offenses.reject { |o| DirtyCop.bury_evidence?(file.path, o.line) }
      [offenses, updated]
    end
  end
end

DirtyCop.process_bribe

exit RuboCop::CLI.new.run
