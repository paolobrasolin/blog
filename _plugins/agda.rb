require "open3"

# This plugin hooks into the Jekyll pipeline to preprocess literate Agda files, highlight them and generate browsable links.
#
# One could feed to `agda --interaction-json` something like `IOTCM "foo.lagda.md" NonInteractive Indirect ( Cmd_load "foo.lagda.md" ["."] )`, but that would require nontrivial processing.
# Luckily, `agda --html` comes to rescue with the `--html-highlight=auto` which keeps all background markdown intact, and we can get away with simply `agda --html --html-highlight=auto --html-dir=html foo.lagda.md`.
#
# Note that you'll need to add this to your `_config.yml`
#   ```yaml
#   exclude:
#     - .agda-html
#   ````
# and this to your `.gitignore`
#   ```
#   *.agdai
#   .agda-html/
#   ```
#
# TODO:
#   * make this work in CI
#   * have some caching mechanism to avoid always re-typechecking everything
#   * handle lagda pages which load other lagda pages as modules (necessary? possible?)
#   * either calculate BROWSABLE_STDLIB_ROOT (meh) or insert all formatted html into the final result (better)
#   * provide Agda.css dynamically instead of using a static asset
#
# References:
#   * https://agda.readthedocs.io/en/v2.6.2.1/tools/generating-html.html#generating-html
#   * https://jekyllrb.com/docs/plugins/hooks/#built-in-hook-owners-and-events

BROWSABLE_STDLIB_ROOT = "https://agda.github.io/agda-stdlib/v1.5"

Jekyll::Hooks.register [:documents, :pages], :pre_render do |resource|
  if resource.path.end_with?(".lagda.md")

    html = Pathname.new(".agda-html").join(resource.relative_path)
    html.mkpath

    source = html.join(resource.basename)
    source.write(resource.content)

    Jekyll.logger.writer << 'Typechecking Agda: '.rjust(20)
    Jekyll.logger.writer << "??".yellow + " " + resource.relative_path

    _stdout, _stderr, status = Open3.capture3(
      [
        "agda",
        "--html",
        "--html-highlight=auto",
        "--html-dir=html", # which is the default
        source.basename,
      ].join(" "),
      chdir: source.dirname,
    )

    if status.success?
      content = html.join("html", source.basename.sub(/\.lagda\.md$/, ".md")).read

      itself = source.basename.sub(/\.lagda\.md$/, ".html").to_s
      content.gsub!(/<pre class="Agda">.*?<\/pre>/m) do |pre|
        pre.gsub(/(?<=href=").*?(?=#\d+")/) do |href|
          href == itself ? "" : "#{BROWSABLE_STDLIB_ROOT}/#{href}"
        end
      end

      content.gsub!(/(?<=href=")#{source.basename.sub(/\.lagda\.md$/, ".html")}(?=#\d+")/, "")
      resource.content = content
      Jekyll.logger.writer << "\b" * resource.relative_path.length + "\b\b\bOK\n".green
    else
      Jekyll.logger.writer << "\b" * resource.relative_path.length + "\b\b\bKO\n".red
    end
  end
end
