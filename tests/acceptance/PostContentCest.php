<?php namespace Dummy\Dummy;
use Dummy\Dummy\AcceptanceTester;

class PostContentCest
{
    public function _before(AcceptanceTester $I)
    {
    }

    // tests
    public function seeAppendedPostContent(AcceptanceTester $I)
    {
        $I->amOnPage('/?p=1');
        $I->dontSee('You’re really not going to like it');
        $I->see('Forty-two');
    }
}
