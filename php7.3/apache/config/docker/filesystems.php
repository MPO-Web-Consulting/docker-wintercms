<?php
/*
| For additional options see
| https://github.com/wintercms/winter/blob/develop/config/filesystems.php
*/

return [
	'disks' => [
		'local' => [
			'driver' => 'local',
			'root'   => storage_path('app'),
			'url'    => '/storage/app',
		],
		's3' => [
			'driver'      => 's3',
			'key'         => env('FILESYSTEM_S3_KEY', ''),
			'secret'      => env('FILESYSTEM_S3_SECRET', ''),
			'region'      => env('FILESYSTEM_S3_REGION', ''),
			'bucket'      => env('FILESYSTEM_S3_BUCKET', ''),
			// 'url'      => env('FILESYSTEM_S3_URL', ''),
			'endpoint' => env('FILESYSTEM_S3_ENDPOINT', ''),
		],
	],
];
