module.exports = function(grunt) {
  grunt.initConfig({
    sass: {
      dist: {
        options: {
          style: 'expanded',
          loadPath: require('node-bourbon').includePaths
        },
        files: {
          "./dist/css/main.css": "./css/main.scss"
        }
      }
    },
    copy: {
      main: {
        files: [
          {expand: true, src: ['images/*'], dest: 'dist/', filter: 'isFile'},
          {expand: true, src: ['favicon.ico'], dest: 'dist/', filter: 'isFile'},
        ],
      },
    },
  });

  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.loadNpmTasks('grunt-contrib-copy');

  grunt.registerTask('default', ['copy', 'sass']);
};
