gulp = require("gulp")
# slim = require("gulp-slim")
jade = require("gulp-jade")
coffee = require("gulp-coffee")
uglify = require("gulp-uglify")
compass = require("gulp-compass")
csso = require("gulp-csso")
clean = require("gulp-clean")
livereload = require("gulp-livereload")
path = require("path")
plumber = require("gulp-plumber")

#
# template
#
gulp.task "template", ->
  gulp.src [
    "src/client/*.jade"
    "!src/client/layout.jade"
  ]
  .pipe plumber()
  .pipe jade pretty: true
  .pipe gulp.dest "tmp/client"
  .pipe livereload()

#
# javascript
#
gulp.task "coffee", ->
  gulp.src("src/client/javascripts/**/*.coffee")
    .pipe plumber()
    .pipe coffee()
    .pipe gulp.dest("tmp/client/javascripts")
    .pipe livereload()

gulp.task "js", ->
  gulp.src([
    "tmp/client/javascripts/**/*.js"
    "!tmp/client/javascripts/components/**/*.js"
  ])
    .pipe plumber()
    .pipe uglify()
    .pipe gulp.dest("build/client/javascripts")
  # Copy vendor files
  gulp.src("tmp/client/javascripts/components/**/*.js")
    .pipe plumber()
    .pipe gulp.dest("build/client/javascripts/components")

#
# css
#
gulp.task "compass", ->
  gulp.src("src/client/stylesheets/**/*.sass")
    .pipe plumber()
    .pipe compass(
      comments: false
      sass: "src/client/stylesheets"
      css: "tmp/client/stylesheets"
      image: "tmp/client/images"
      # require: ['susy']
    )
    .pipe(gulp.dest("tmp/client/stylesheets"))
    .pipe livereload()

gulp.task "css", ->
  # Minify and copy all JavaScript (except vendor scripts)
  gulp.src([
    "tmp/client/stylesheets/**/*.css"
    "!tmp/client/stylesheets/vendor/**"
  ])
    .pipe plumber()
    .pipe csso()
    .pipe gulp.dest("build/client/stylesheets")
  # Copy vendor files
  gulp.src("tmp/client/stylesheets/vendor/**")
    .pipe plumber()
    .pipe gulp.dest("build/client/stylesheets/vendor")

#
# static
#
gulp.task "copy", ->
  gulp.src("tmp/client/images/**")
    .pipe plumber()
    .pipe gulp.dest("build/client/images")
  gulp.src("tmp/*.js")
    .pipe plumber()
    .pipe uglify()
    .pipe gulp.dest("build/")
  gulp.src("tmp/client/*.html")
    .pipe plumber()
    .pipe gulp.dest("build/client/")

#
# server
#
gulp.task  "server", ->
  gulp.src("src/*.coffee")
    .pipe plumber()
    .pipe coffee()
    .pipe gulp.dest("tmp/")
    .pipe livereload()

#
# command
#
gulp.task "watch", ->
  gulp.watch "src/client/javascripts/**", ["coffee"]
  gulp.watch "src/client/stylesheets/**", ["compass"]
  gulp.watch "src/client/*", ["template"]
  gulp.watch "src/*", ["server"]


gulp.task "default", ["template" , "coffee", "js", "compass", "css", "copy", "server", "watch"]

gulp.task "clean", ->
  gulp.src("build").pipe clean()
