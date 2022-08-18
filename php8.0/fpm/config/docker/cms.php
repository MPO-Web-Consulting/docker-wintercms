<?php
/*
| For additional options see
| https://github.com/wintercms/winter/blob/master/config/cms.php
*/

return [
	'activeTheme' => env('CMS_ACTIVE_THEME', 'demo'),
	'edgeUpdates' => env('CMS_EDGE_UPDATES', false),
	'backendUri' => env('CMS_BACKEND_URI', 'backend'),
	'backendForceSecure' => env('CMS_BACKEND_FORCE_SECURE', false),
	'backendTimezone' => env('TZ', 'UTC'),
	'backendSkin' => env('CMS_BACKEND_SKIN', 'Backend\Skins\Standard'),
	'disableCoreUpdates' => env('CMS_DISABLE_CORE_UPDATES', true),
	'linkPolicy' => env('CMS_LINK_POLICY', 'detect'),
	'databaseTemplates' => env('CMS_DATABASE_TEMPLATES', false),
	'defaultMask' => [
		'file' => env('CMS_DEFAULT_MASK_FILE', '664'),
		'folder' =>  env('CMS_DEFAULT_MASK_FOLDER', '775'),
	],
	'storage' => [
		'uploads' => [
			'disk'            => 'local',
			'folder'          => 'uploads',
			'path'            => '/storage/app/uploads',
			'temporaryUrlTTL' => 3600,
		],
		'media' => [
			'disk'   => env('CMS_MEDIA_DISK', 'local'),
			'folder' => env('CMS_MEDIA_FOLDER', 'media'),
			'path'   => env('CMS_MEDIA_PATH', '/storage/app/media')
		],
		'resized' => [
			'disk'   => 'local',
			'folder' => 'resized',
			'path'   => '/storage/app/resized',
		],
	],
];
