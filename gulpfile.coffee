Q = require('q')

gulp = require("gulp")
component = require('gulp-component')
jade = require("gulp-jade")
coffee = require("gulp-coffee")
uglify = require("gulp-uglify")
compass = require("gulp-compass")
csso = require("gulp-csso")
clean = require("gulp-clean")
livereload = require("gulp-livereload")
plumber = require("gulp-plumber")

#
# template
#
gulp.task "template", ->
  gulp.src [
    "src/client/index.jade"
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
    .pipe coffee bare: true
    .pipe gulp.dest("tmp/client/javascripts")
gulp.task "component", ["coffee"], ->
  deferred = Q.defer()
  gulp.src 'component.json'
    .pipe component standalone: true
    .pipe gulp.dest('tmp/client/build')
    .pipe livereload()
  deferred.resolve()
  deferred.promise

#
# css
#
gulp.task "compass", ->
  gulp.src("src/client/stylesheets/style.sass")
    .pipe plumber()
    .pipe compass(
      comments: false
      sass: "src/client/stylesheets"
      css: "tmp/client/stylesheets"
      image: "tmp/client/images"
      require: ['breakpoint']
    )
    .pipe(gulp.dest("tmp/client/stylesheets"))
    .pipe livereload()

gulp.task "css", ->
  gulp.src([
    "tmp/client/stylesheets/**/*.css"
    "!tmp/client/stylesheets/vendor/**"
  ])
    .pipe plumber()
    .pipe csso()
    .pipe gulp.dest("build/client/stylesheets")
  gulp.src("tmp/client/stylesheets/vendor/**")
    .pipe plumber()
    .pipe gulp.dest("build/client/stylesheets/vendor")

#
# static
#
gulp.task "copy", ->
  gulp.src("tmp/client/images/**")
    .pipe gulp.dest("build/client/images")
  gulp.src("tmp/*.js")
    .pipe gulp.dest("build/")
  gulp.src("tmp/client/*.html")
    .pipe gulp.dest("build/client/")
  gulp.src(["tmp/client/build/**"])
    .pipe uglify()
    .pipe gulp.dest("build/client/build/")
  gulp.src("tmp/vendor/**")
    .pipe gulp.dest("build/vendor/")

#
# server
#
gulp.task  "server", ->
  gulp.src("src/*.coffee")
    .pipe plumber()
    .pipe coffee bare: true
    .pipe gulp.dest("tmp/")
    .pipe livereload()

#
# command
#
gulp.task "watch", ->
  gulp.watch "src/client/javascripts/**", ["component"]
  gulp.watch "src/client/stylesheets/**", ["compass"]
  gulp.watch "src/client/*", ["template"]
  gulp.watch "src/*", ["server"]

gulp.task "default", ["template" , "component", "compass", "css", "server", "watch"]
gulp.task "build", ["template" , "component", "compass", "css", "server", "copy"]

gulp.task "clean", ->
  gulp.src("build").pipe clean()
