<?php
/*
| For additional options see
| https://github.com/wintercms/winter/blob/master/config/mail.php
*/

return [
    'driver' => env('MAIL_DRIVER', 'log'), // smtp, log, etc
    'host' => env('MAIL_SMTP_HOST'),
    'port' => env('MAIL_SMTP_PORT', '587'),
    'from' => [
      'address' => env('MAIL_FROM_ADDRESS', 'no-reply@domain.tld'),
      'name' => env('MAIL_FROM_NAME', 'WinterCMS')
    ],
    'encryption' => env('MAIL_SMTP_ENCRYPTION', 'tls'),
    'username' => env('MAIL_SMTP_USERNAME'),
    'password' => env('MAIL_SMTP_PASSWORD'),
];
