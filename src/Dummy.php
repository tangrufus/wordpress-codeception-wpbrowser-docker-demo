<?php
declare(strict_types=1);

namespace Dummy\Dummy;

class Dummy
{
    public static function getMagicNumber(): int
    {
        return 42;
    }

    public static function getQuestion(): string
    {
        return sanitize_text_field('<p>The Answer to the Great Question of Life, the Universe and Everything: <q cite="Deep Thought">Forty-two.</q></p>');
    }

    public static function renderAdminNotice(): void
    {
        echo '<div class="notice notice-success is-dismissible">';
        echo "<p>What is the Answer to the Great Question of Life, the Universe and Everything?</p>";
        echo '</div>';
    }

    public static function appendPostContent(string $content): string
    {
        return $content . '<div><p>The Answer to the Great Question of Life, the Universe and Everything: <span id="dummy-answer">You’re really not going to like it</span></p></div>';
    }
}
