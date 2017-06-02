module.exports = function(grunt) {
  grunt.initConfig({
    sass: {
      dist: {
        options: {
          style: 'expanded',
          includePaths: require('node-bourbon').includePaths
        },
        files: {
          "./priv/static/dist/css/main.css": "./priv/static/src/css/main.scss"
        }
      }
    },
    copy: {
      main: {
        files: [
          {expand: true, cwd: 'priv/static/src/', src: ['images/*'], dest: 'priv/static/dist/', filter: 'isFile'},
          {expand: true, cwd: 'priv/static/src/', src: ['favicon.ico'], dest: 'priv/static/dist/', filter: 'isFile'},
          {expand: true, cwd: 'priv/static/src/', src: ['js/*.js'], dest: 'priv/static/dist/', filter: 'isFile'},
        ],
      },
    },
    watch: {
      scripts: {
        files: 'priv/static/src/**/*',
        tasks: ['sass', 'copy'],
        options: {
          interrupt: true,
        },
      },
    },
  });

  grunt.loadNpmTasks('grunt-sass');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['copy', 'sass']);
};
