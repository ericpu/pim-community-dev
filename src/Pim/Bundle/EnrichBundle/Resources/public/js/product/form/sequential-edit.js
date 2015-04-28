'use strict';

define(
    [
        'jquery',
        'underscore',
        'backbone',
        'oro/mediator',
        'pim/form',
        'text!pim/template/product/sequential-edit',
        'routing',
        'oro/navigation',
        'pim/product-manager',
        'pim/entity-manager'
    ],
    function (
        $,
        _,
        Backbone,
        mediator,
        BaseForm,
        template,
        Routing,
        Navigation,
        ProductManager,
        EntityManager
    ) {
        return BaseForm.extend({
            id: 'sequentialEdit',
            template: _.template(template),
            events: {
                'click .next, .previous': 'followLink'
            },
            initialize: function () {
                this.model = new Backbone.Model();
            },
            configure: function () {
                return $.when(
                    EntityManager.getRepository('sequentialEdit').findAll().then(
                        _.bind(function (sequentialEdit) {
                            this.model.set(sequentialEdit);
                        }, this)
                    ),
                    BaseForm.prototype.configure.apply(this, arguments)
                );
            },
            render: function () {
                if (!this.configured || !this.model.get('objectSet')) {
                    return this;
                }

                this.getTemplateParameters().done(_.bind(function (templateParameters) {
                    this.$el.html(this.template(templateParameters));
                    this.delegateEvents();
                }, this));

                return this;
            },
            getTemplateParameters: function () {
                var deferred = $.Deferred();

                var objectSet = this.model.get('objectSet');
                var currentObject = this.getData().meta.id;
                var index = objectSet.indexOf(currentObject);
                var previous = objectSet[index - 1];
                var next = objectSet[index + 1];

                var previousObject = null;
                var nextObject = null;

                var promises = [];
                if (previous) {
                    promises.push(ProductManager.get(previous).then(function (product) {
                        previousObject = product;
                    }));
                }
                if (next) {
                    promises.push(ProductManager.get(next).then(function (product) {
                        nextObject = product;
                    }));
                }

                $.when.apply($, promises).done(function () {
                    deferred.resolve(
                        {
                            objectCount:    objectSet.length,
                            currentIndex:   index + 1,
                            previousObject: previousObject,
                            nextObject:     nextObject,
                            ratio:          (index + 1) / objectSet.length * 100
                        }
                    );
                });

                return deferred.promise();
            },
            followLink: function (event) {
                Navigation.getInstance().setLocation(
                    Routing.generate(
                        'pim_enrich_product_edit',
                        { id: event.currentTarget.dataset.id }
                    )
                );
            }
        });
    }
);
