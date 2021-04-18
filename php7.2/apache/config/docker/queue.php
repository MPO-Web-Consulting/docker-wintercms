<?php
/*
| For additional options see
| https://github.com/wintercms/winter/blob/master/config/queue.php
*/

return [
    'default' => env('QUEUE_DRIVER', 'sync'),
    'failed' => [
        'database' => env('DB_TYPE','sqlite')
    ],
];
