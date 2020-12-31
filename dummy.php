<?php

/**
 * Plugin Name:       Dummy
 * Plugin URI:        https://github.com/tangrufus/wordpress-codeception-wpbrowser-docker-demo
 * Description:       Dummy
 * Version:           0.0.1
 * Requires at least: 5.6
 * Requires PHP:      7.4
 * Author:            Tang Rufus
 * Author URI:        https://typist.tech/
 * License:           MIT
 * License URI:       https://opensource.org/licenses/MIT
 * Text Domain:       dummy
 */

declare(strict_types=1);

namespace Dummy\Dummy;

// If this file is called directly, abort.
if (! defined('WPINC')) {
    die;
}

if (file_exists(__DIR__ . '/vendor/autoload.php')) {
    require_once __DIR__ . '/vendor/autoload.php';
}

add_action('admin_notices', [Dummy::class, 'renderAdminNotice']);
add_action('the_content', [Dummy::class, 'appendPostContent']);
add_action('wp_enqueue_scripts', function () {
    wp_enqueue_script('dummy-js', plugins_url('src/dummy.js', __FILE__));
});
